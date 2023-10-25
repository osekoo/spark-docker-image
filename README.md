# Spark Docker Image

## Building

Use the following command to build spark docker image

```shell
spark_version=3.5.0  
java_version=17  
sbt_version=1.9.7  

docker rmi osekoo/spark:$spark_version \
    --build-arg="SPARK_VERSION=$spark_version" \
    --build-arg="JAVA_VERSION=$java_version" \  
    --build-arg="SBT_VERSION=$sbt_version"
```

## Running with docker compose

### As Master
Launch spark master service:

````shell
services:
  spark-master:
    image: osekoo/spark:3.5.0
    container_name: spark-master
    environment:
      - SPARK_MODE=master
    ports:
      - '7077:7077'
      - '8080:8080'
````

### As Worker
Spark worker connecting to spark master. the master should be running first.  
`replicas` parameter holds the number of workers to instantiate.

````shell
services:
  spark-worker:
    image: osekoo/spark:3.5.0
    environment:
      - SPARK_MODE=worker
      - SPARK_WORKER_MEMORY=1G
      - SPARK_WORKER_CORES=2
    deploy:
      replicas: 2
    depends_on:
      - spark-master
````

### As Client
In `client` mode, the app executes `spark-submit` commands with the following arguments.

````shell
services:
  spark-client:
      image: osekoo/spark:3.5.0
      container_name: spark-client
      environment:
        - SPARK_MODE=client
        - APP_SBT_BUILD=
        - APP_SBT_CLEAN=
        - APP_DEPLOY_MODE=client
        - APP_DEPENDENCIES=
        - APP_JARS=
        - APP_FILES=
        - APP_CLASS=
        - APP_PACKAGE=
        - APP_ARGS=
      ports:
        - '4040:4040'
      volumes:
        - "./:/app"
      depends_on:
        - spark-worker
````
<table>
    <tr><td>Variable</td><td>Definition</td><td>Default value</td></tr>
    <tr>
      <td>APP_SBT_BUILD</td>
      <td>package the app using sbt command `sbt package`</td>
      <td>false</td>
    </tr>
    <tr>
        <td>APP_SBT_CLEAN</td>
        <td>clean up the app output when set to true</td>
        <td>false</td>
    </tr>
    <tr>
        <td>APP_DEPLOY_MODE</td>
        <td><i>spark-submit --deploy-mode</i></td>
        <td>`client`</td>
    </tr>
    <tr>
        <td>APP_DEPENDENCIES</td>
        <td><i>spark-submit --packages</i></td>
        <td></td>
    </tr>
    <tr>
        <td>APP_JARS</td>
        <td><i>spark-submit --jars</i></td>
        <td></td>
    </tr>
    <tr><td>APP_FILES</td>
        <td><i>spark-submit --files</i></td>
        <td></td>
    </tr>
    <tr><td>APP_CLASS</td>
        <td><i>spark-submit --class</i></td>
        <td></td>
    </tr>
    <tr><td>APP_PACKAGE</td>
        <td>the application jar file</td>
        <td></td>
    </tr>
    <tr><td>APP_ARGS</td>
        <td>the application arguments</td>
        <td></td>
    </tr>
</table>