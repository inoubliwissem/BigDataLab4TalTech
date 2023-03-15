FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y vim \
    wget \
    ssh \
    scala \
    sudo \
    openjdk-8-jdk \
    pip \
    bpython \
    git
# create a hadoop user set it to sudoer and passwordless
RUN useradd -m hduser && \
    echo "hduser:hduser" | chpasswd && \
    adduser hduser sudo && \
    echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# set hadoop user as default user
USER hduser
WORKDIR /home/hduser
# create a ssh key for hadoop user
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys
# create a ssh config file
RUN echo "Host *" >> ~/.ssh/config && \
    echo " StrictHostKeyChecking no" >> ~/.ssh/config && \
    echo " UserKnownHostsFile=/dev/null" >> ~/.ssh/config
# install hadoop and spark
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.2/hadoop-3.3.2.tar.gz && \
    tar -xzvf hadoop-3.3.2.tar.gz && \
    mv hadoop-3.3.2 hadoop && \
    rm hadoop-3.3.2.tar.gz
RUN wget https://dlcdn.apache.org/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz && \
    tar -xzf spark-3.3.2-bin-hadoop3.tgz && \
    mv spark-3.3.2-bin-hadoop3 spark && \
    rm spark-3.3.2-bin-hadoop3.tgz
RUN pip install notebook pyspark
# set hadoop and spark environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV HADOOP_HOME=/home/hduser/hadoop
ENV SPARK_HOME=/home/hduser/spark
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:/home/hduser/.local/bin
# create hadoop directories
RUN mkdir -p /home/hduser/hadoop/hdfs/namenode && \
    mkdir -p /home/hduser/hadoop/hdfs/datanode && \
    mkdir -p /home/hduser/hadoop/hdfs/logs && \
    mkdir -p /home/hduser/hadoop/hdfs/tmp
# set hadoop configuration files
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> /home/hduser/hadoop/etc/hadoop/hadoop-env.sh
COPY config/core-site.xml /home/hduser/hadoop/etc/hadoop/core-site.xml
COPY config/hdfs-site.xml /home/hduser/hadoop/etc/hadoop/hdfs-site.xml
COPY config/mapred-site.xml /home/hduser/hadoop/etc/hadoop/mapred-site.xml
COPY config/yarn-site.xml /home/hduser/hadoop/etc/hadoop/yarn-site.xml
# format namenode
RUN hdfs namenode -format
# copy the spark env file
COPY config/spark-env.sh /home/hduser/spark/conf/spark-env.sh
# edit spark-defaults.conf
RUN echo "spark.master spark://localhost:7077" >> /home/hduser/spark/conf/spark-defaults.conf
# expose ports
EXPOSE 4040 8080 8888 9870 7077 