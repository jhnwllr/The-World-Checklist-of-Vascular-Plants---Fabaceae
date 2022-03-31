val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import sqlContext.implicits._

val df_original = sqlContext.sql("SELECT * FROM prod_h.occurrence")

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

val df_export = df_original.
filter(array_contains(col("issue"), "TAXON_MATCH_HIGHERRANK")).
filter($"family" === "Fabaceae"). 
filter($"v_scientificname" rlike """^\b\w{4,} \w{4,}\b""").
filter(!$"basisofrecord".isin(exclude_basis_of_record:_*)).
filter(!col("v_scientificname").rlike(black_list.mkString("|"))).
groupBy("v_scientificname","taxonrank").
count()

import sys.process._
import org.apache.spark.sql.SaveMode

val save_table_name = "legume_unmatched"

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

