val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import sqlContext.implicits._
import org.apache.spark.sql.functions._

val df_ulex = sqlContext.sql("SELECT * FROM jwaller.occurrence_20210204").
filter($"hascoordinate" === true).
filter($"hasgeospatialissues" === false).
filter($"family" === "Fabaceae").
filter($"genus" === "Ulex").
filter(array_contains(col("issue"), "TAXON_MATCH_HIGHERRANK"))


val df_export = df_ulex.groupBy("v_scientificname","taxonrank","scientificname").count().orderBy(desc("count"))

df_export.show()

import sys.process._
import org.apache.spark.sql.SaveMode

val save_table_name = "ulex_table"

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






