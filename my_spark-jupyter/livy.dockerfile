FROM docker.io/bitnami/spark:3.5


USER root
COPY livy/livy.zip /root
RUN apt-get update && apt-get install -y unzip
RUN unzip /root/livy.zip -d /opt/
RUN mv /opt/apache-livy-0.8.0-incubating_2.11-bin /opt/livy

COPY livy/conf/livy-env.sh /opt/livy/conf/livy-env.sh
COPY livy/conf/livy.conf /opt/livy/conf/liy.conf

ENTRYPOINT ["/opt/livy/bin/livy-server","start"]
