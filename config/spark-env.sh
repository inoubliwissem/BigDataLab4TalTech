export PYSPARK_DRIVER_PYTHON=bpython
export SPARK_MASTER_HOST=localhost
export SPARK_LOCAL_IP=localhost
export SPARK_MASTER_OPTS="-Dspark.driver.bindAddress=127.0.0.1 -Dspark.driver.host=127.0.0.1 -Dspark.driver.memory=4g -Dspark.driver.cores=8 -Dspark.executor.memory=4g -Dspark.executor.cores=8"
export SPARK_WORKER_OPTS="-Dspark.worker.memory=4g -Dspark.worker.cores=8 -Dspark.executor.memory=4g -Dspark.executor.cores=8"