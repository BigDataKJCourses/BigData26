# List of Containers

Below is a brief overview of the purpose and function of each container in the environment.

## Kafka & ksqlDB
This section serves as the "circulatory system" for data streams within the infrastructure.

* `kafka-1`, `kafka-2`, `kafka-3` – Three nodes of an Apache Kafka cluster operating in *KRaft* mode (Zookeeperless). They function as a distributed message broker. The three-node setup ensures high availability and fault tolerance in case of a broker failure.

* `ksqldb-server` – The SQL engine for Kafka, enabling "in-flight" data transformations using SQL syntax (e.g., filtering, aggregations, joining streams).

* `ksqldb-cli` – A command-line interface for *ksqlDB*, allowing you to manually execute SQL queries against the *ksqlDB* server.

* `kafka-ui` – A web-based graphical user interface to browse topics, messages, and monitor the cluster status without using the terminal.

## Compute Layer (Spark & Flink)
Engines designed for heavy-duty analytical tasks and ETL processes.

* `spark-master` – The *Apache Spark* cluster manager, responsible for resource allocation, application coordination, and hosting *Spark* drivers.

* `spark-worker` – Worker nodes where physical data processing occurs; they host *Spark* executors that process data as instructed by the drivers. This component is scalable.

* `flink-jobmanager` – The "brain" of *Apache Flink*. It accepts stream processing jobs, builds dataflow graphs, and manages their execution.

* `flink-taskmanager` – The execution container for *Apache Flink*, providing task slots where real-time stream processing takes place. This component is scalable.

## Storage and Database Layer
The permanent home for data or a source for analysis.

* `mysql` – A traditional relational database used as a data source or a destination for storing analytical results.

* `minio` – A local, S3-compatible alternative to Amazon S3. It serves as a Data Lake for storing files (Parquet, CSV, JSON) and acts as a storage point for *Flink* and *Spark Structured Streaming* checkpoints.

## Analytical Layer (User Interface)
The interface for the developer and data analyst.

* `jupyter` – The *JupyterLab* environment. This is where you write Python (PySpark) code that connects to all (or selected) components mentioned above to create reports and Machine Learning (ML) models.

## Summary
All these containers operate within a virtual network named `stream-net`. This allows them to communicate using their service names (for example, *Apache Spark* can reach *MinIO* at http://minio:9000).

# List of Volumes
In the BigData26 environment, the data management system relies on two types of volumes:

* *Named Volumes* – used for the persistent storage of database states and message logs.
* *Bind Mounts* – which act as "bridges" between your host system and the containers.

## Mounted Volumes
These volumes map specific folders from your host machine directly into the containers. They are crucial for development and persistent storage.

* `shared_workspace` (`./shared_workspace -> /opt/workspace`)
This volume acts as a shared disk space between the host machine and several containers.
Use case: Sharing Python scripts (.py), SQL files, and raw datasets (CSV, JSON).

* `notebooks` (`./notebooks -> /home/jovyan/work`)
A dedicated space specifically for *JupyterLab*.
Use case: Storing `.ipynb` files (*Jupyter Notebooks*).

* `lib-shared` (`./lib-shared -> /opt/flink/lib/shared` and `/home/jovyan/lib-shared`)
A special folder for additional JAR libraries that you don't want to permanently "bake" into the Docker images.
Use case: Adding custom connectors or drivers on the fly.

### Named Volumes
These are managed entirely by Docker. Their primary purpose is to protect data from being deleted when containers are restarted (e.g., after `docker compose down` — **Note:** Avoid using the `-v` flag, as it forces the removal of these volumes).

| Volume Name | Service | Characteristics |
| :--- | :--- | :--- |
| **mysql_data** | MySQL | Stores MySQL databases. |
| **minio_data** | MinIO | Emulates S3 cloud storage. This is where your data "buckets" for analysis are stored. |
| **kafka_data_1/2/3** | Kafka | Stores Kafka topic partitions along with their messages. |

### Profiles
The use of Docker profiles allows for **modular resource management**. This means you don't have to launch the entire stack at once, which prevents the environment from consuming all available RAM.

There are four main profiles, each corresponding to a different stage of data processing:

| Profile Name | Services / Containers | When to use? |
| :--- | :--- | :--- |
| **kafka** | `kafka-1`, `2`, `3`, `kafka-ui`, `ksqldb-server`, `ksqldb-cli` | During *Kafka* and *ksqlDB* workshops, or whenever *Apache Spark/Flink* needs to interact with *Kafka* topics. |
| **flink** | `flink-jobmanager`, `flink-taskmanager` | During *Apache Flink* workshops. |
| **spark** | `spark-master`, `spark-worker` | During *Apache Spark* and *Spark Structured Streaming* workshops. |
| **jupyter** | `jupyterlab` | Whenever you want to work interactively using *Python* notebooks. |