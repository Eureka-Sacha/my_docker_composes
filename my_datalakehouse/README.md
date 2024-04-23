## 如何运行

1. 准备docker compose 运行环境
2. 下载项目
3. 运行docker compose up -d
4. 运行docker compose logs -f 查看运行日志

## 如何配置dremio S3 like 数据源（minio）

1. 在minio 中创建bucket，创建access key。
2. 登录dremio UI -> add source -> aws s3
3. 取消Encrypt connection 选项
4. 进入 advanced options 页面 -> 打开 compatibility mode
5. 添加两行property
    - fs.s3a.endpoint= <ip/host>:9000
    - fs.s3a.path.style.access=true
6. 添加allowlisted bucket

## 如何配置dremio 元数据存储为minio

1. 在minio中创建dremio bucket
2. 修改 dremio.conf 配置
    ```
    paths: {
    ...
    dist: "dremioS3:///<bucket_name>/<folder1>/<folder2>"
    }
   ```
3. 添加core-site.xml 配置文件(注意替换ak,sk,endpoint，SSL_ENABLED等信息)
   ```xml
   <?xml version="1.0"?>
   <configuration>
   <property>
       <name>fs.dremioS3.impl</name>
       <description>The FileSystem implementation. Must be set to com.dremio.plugins.s3.store.S3FileSystem</description>
       <value>com.dremio.plugins.s3.store.S3FileSystem</value>
   </property>
   <property>
       <name>fs.s3a.access.key</name>
       <description>Minio server access key ID.</description>
       <value>ACCESS_KEY</value>
   </property>
   <property>
       <name>fs.s3a.secret.key</name>
       <description>Minio server secret key.</description>
       <value>SECRET_KEY</value>
   </property>
   <property>
       <name>fs.s3a.aws.credentials.provider</name>
       <description>The credential provider type.</description>
       <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
   </property>
   <property>
       <name>fs.s3a.endpoint</name>
       <description>Endpoint can either be an IP or a hostname, where Minio server is running . However the endpoint value cannot contain the http(s) prefix. E.g. 175.1.2.3:9000 is a valid endpoint. </description>
       <value>ENDPOINT</value>
   </property>
   <property>
       <name>fs.s3a.path.style.access</name>
       <description>Value has to be set to true.</description>
       <value>true</value>
   </property>
   <property>
       <name>dremio.s3.compat</name>
       <description>Value has to be set to true.</description>
       <value>true</value>
   </property>
   <property>
       <name>fs.s3a.connection.ssl.enabled</name>
       <description>Value can either be true or false, set to true to use SSL with a secure Minio server.</description>
       <value>SSL_ENABLED</value>
   </property>
   </configuration>
   ```

## 如何使用spark向minio写入定量数据

1. 进入spark-work容器
2. 执行以下命令（存在下载过程，需联网）
   ```shell
   ./bin/spark-shell \
   --packages io.delta:delta-core_2.12:1.0.0,org.apache.hadoop:hadoop-aws:3.2.0 \
   --conf "spark.hadoop.fs.s3a.access.key=admin" \
   --conf "spark.hadoop.fs.s3a.secret.key=admin123" \
   --conf "spark.hadoop.fs.s3a.endpoint=http://192.168.1.2:9000" \
   --conf "spark.databricks.delta.retentionDurationCheck.enabled=false" \
   --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
   --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
   
   // 1.创建一个一亿行的delta数据集
   spark.range(100000000).write.format("delta").save("s3a://datalake/demo")
   
   // 2.创建一个包含1亿行
   spark.range(100000000).select(
   (rand(seed=42) * 1000).cast("int").alias("column1"),
   (rand(seed=24) * 1000).cast("int").alias("column2"),
   (rand(seed=66) * 1000).cast("int").alias("column3")
   ).write.format("delta").save("s3a://datalake/demo2")
   
   // 3.创建一个1000万的csv
   spark.range(10000000).select(
   (rand(seed=42) * 1000).cast("int").alias("column1"),
   (rand(seed=24) * 1000).cast("int").alias("column2"),
   (rand(seed=66) * 1000).cast("int").alias("column3")
   ).write.option("header", "true").csv("s3a://datalake/demo3")
    ```

## 如何在metadata上配置dremio