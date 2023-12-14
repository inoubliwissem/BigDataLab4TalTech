# specifiy the image ' OS
FROM ubuntu:20.04
MAINTAINER Wissem Inoubli (inoubliwissem@gmail.com)
# install the required softwares (JDK, openssh, wget)
RUN apt-get update -y && apt-get install vim -y && apt-get install wget -y && apt-get install ssh -y && apt-get install openjdk-8-jdk -y && apt-get install sudo -y && apt-get install scala -y
# create a new user and add it as sudoer
RUN useradd -m hduser && echo "hduser:supergroup" | chpasswd && adduser hduser sudo && echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ &&  ln -s python3 python
# set the workspace
WORKDIR /home/hduser
# switech to the created user
USER hduser
# download hadoop and extract it
RUN wget -q https://downloads.apache.org/hadoop/common/hadoop-3.2.4/hadoop-3.2.4.tar.gz && tar zxvf hadoop-3.2.4.tar.gz && rm hadoop-3.2.4.tar.gz
RUN mv hadoop-3.2.4 hadoop
# share the public key
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys	
# set environment variable
ENV HADOOP_HOME=/home/hduser/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/sbin
ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}
ENV HADOOP_COMMON_HOME=${HADOOP_HOME}
ENV HADOOP_HDFS_HOME=${HADOOP_HOME}
ENV YARN_HOME=${HADOOP_HOME}
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-arm64
COPY ssh_config /etc/ssh/ssh_config
# create hdfs directories 
RUN mkdir -p hadoop/hdfs/datanode
RUN mkdir -p hadoop/hdfs/namenode
RUN mkdir -p hadoop/logs
#set the hadoop configation files
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-arm64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY start.sh $HADOOP_HOME/etc/hadoop/
#Spark configuration
RUN wget https://www.apache.org/dyn/closer.lua/spark/spark-3.2.4/spark-3.2.4-bin-hadoop3.2.tgz && tar zxvf spark-3.2.4-bin-hadoop3.2.tgz && rm spark-3.2.4-bin-hadoop3.2.tgz
RUN mv spark-3.2.4-bin-hadoop3.2 spark
# set environment variable spark
ENV SPARK_HOME=/home/hduser/spark
ENV PATH=$PATH:$SPARK_HOME/bin
#ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-arm64
#open the used ports
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22 7077 7070 8080 8081
