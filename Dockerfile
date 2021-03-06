FROM alpine:3.7

LABEL description='Alpine/Kafka cluster node' \
      maintainer='edward2a@gmail.com'

ARG KAFKA_VERSION=1.1.0
ARG SCALA_VERSION=2.11

RUN apk update && \
    apk add openjdk8-jre-base bash pcre-tools

RUN addgroup -S kafka && \
    adduser -S -D -G kafka kafka

RUN wget http://mirrors.whoishostingthis.com/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mkdir /opt && \
    tar -xf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka && \
    mkdir /opt/kafka/data_kafka

ADD config/broker.properties /opt/kafka/config/server.properties
ADD scripts/container_init.sh /opt/kafka/bin/kafka-init.sh

RUN chmod 755 /opt/kafka/bin/kafka-init.sh

ENTRYPOINT /opt/kafka/bin/kafka-init.sh

ENV PUBLIC_IF=eth0 \
    REPLICATION_IF=eth0 \
    KAFKA_HEAP_OPTS='-Xms384M -Xmx384M' \
    ZK_CLUSTER=127.0.0.1

EXPOSE 9092
