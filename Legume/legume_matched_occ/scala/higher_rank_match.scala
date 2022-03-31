val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import sqlContext.implicits._
import org.apache.spark.sql.functions._

val df_old = sqlContext.sql("SELECT * FROM jwaller.occurrence_20210204").
filter($"hascoordinate" === true).
filter($"hasgeospatialissues" === false).
filter($"family" === "Fabaceae")

val df_cur = sqlContext.sql("SELECT * FROM prod_h.occurrence").
filter($"hascoordinate" === true).
filter($"hasgeospatialissues" === false).
filter($"family" === "Fabaceae")

val exclude_basis_of_record = List("FOSSIL_SPECIMEN","MATERIAL_SAMPLE")

val black_list = List(
"BOLD",
"gen.",
"Mystery mystery",
"Sonus naturalis",
"BOLD",
"gen.",
"sp.",
"SDJB",
"\\ssp",
"VOB",
"indet",
"uncultured ",  
"environmental sample",
"INCERTAE",
"Unplaced",
"Unknown"
)

val df_old_f = df_old.
filter(array_contains(col("issue"), "TAXON_MATCH_HIGHERRANK")).
filter($"v_scientificname" rlike """^\b\w{4,} \w{4,}\b""").
filter(!$"basisofrecord".isin(exclude_basis_of_record:_*)).
filter(!col("v_scientificname").rlike(black_list.mkString("|"))).
select("v_scientificname","scientificname","genus","taxonrank")

val old_names = df_old_f.select("v_scientificname").distinct().collect().map(_(0)).toList

val df_cur_f = df_cur.
filter(array_contains(col("issue"), "TAXON_MATCH_HIGHERRANK")).
filter($"v_scientificname" rlike """^\b\w{4,} \w{4,}\b""").
filter(!$"basisofrecord".isin(exclude_basis_of_record:_*)).
filter(!col("v_scientificname").rlike(black_list.mkString("|"))).
withColumn("is_old_name", $"v_scientificname".isin(old_names:_*)).
filter($"is_old_name").
select("v_scientificname","scientificname","is_old_name","genus","taxonrank")


val rtc = df_cur_f.groupBy("taxonrank").
count().
withColumnRenamed("count","count_c")

val rto = df_old_f.groupBy("taxonrank").
count().
withColumnRenamed("count","count_o")

rtc.join(rto,"taxonrank").withColumn("diff",$"count_o" - $"count_c").show()

+---------+-------+-------+-----+
|taxonrank|count_c|count_o| diff|
+---------+-------+-------+-----+
|   FAMILY|   2535|  17158|14623|
|  SPECIES|  18982|  22913| 3931|
|    GENUS|  25803|  68484|42681|
+---------+-------+-------+-----+

val df_old_g = df_old_f.
groupBy("genus").
count().
withColumnRenamed("count","occ_count_old").
withColumnRenamed("genus","genus_old")

val df_cur_g = df_cur_f.
groupBy("genus").
count().
withColumnRenamed("count","occ_count_new").
withColumnRenamed("genus","genus_new")

val df_export = df_old_g.join(df_cur_g,df_cur_g("genus_new") === df_old_g("genus_old"))

import sys.process._
import org.apache.spark.sql.SaveMode

val save_table_name = "legume_genus_occ"

df_export.
write.format("csv").
option("sep", "\t").
option("header", "false"). // add header later
mode(SaveMode.Overwrite).
save(save_table_name)

// custom downloads dir 
val export_dir = "/mnt/auto/misc/download.gbif.org/custom_download/jwaller/"

// export tsv file from scala to custom downloads 
(s"hdfs dfs -ls")!
(s"rm " + export_dir + save_table_name)!
(s"hdfs dfs -getmerge /user/jwaller/"+ save_table_name + " " + export_dir + save_table_name+ ".tsv")!
(s"head " + export_dir + save_table_name + ".tsv")!
val header = "1i " + df_export.columns.toSeq.mkString("""\t""")
Seq("sed","-i",header,export_dir+save_table_name+".tsv").!
(s"ls -lh " + export_dir)!

System.exit(0)

