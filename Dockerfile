FROM alpine:3.12

LABEL description='Alpine/Kafka cluster node' \
      maintainer='edward2a@gmail.com'

ARG KAFKA_VERSION=2.5.0
ARG SCALA_VERSION=2.13

RUN apk update && \
    apk add openjdk11-jre-headless bash pcre-tools

RUN addgroup -S kafka && \
    adduser -S -D -G kafka kafka

RUN wget http://mirrors.whoishostingthis.com/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    [ -d /opt ] || mkdir /opt && \
    tar -xf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && \
    rm -f kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka && \
    mkdir /opt/kafka/data_kafka /opt/kafka/config-var && \
    chown -R root:kafka /opt/kafka && \
    find /opt/kafka/ -type d -exec chmod 750 {} \+ && \
    find /opt/kafka/ -type f -exec chmod 640 {} \+ && \
    chmod 750 /opt/kafka/bin/*.sh && \
    chmod 770 /opt/kafka/config-var

ADD --chown root:kafka config/broker.properties /opt/kafka/config/server.properties
ADD --chown root:kafka scripts/container_init.sh /opt/kafka/bin/kafka-init.sh

RUN chmod 750 /opt/kafka/bin/kafka-init.sh && \
    chmod 660 /opt/kafka/config/server.properties

ENTRYPOINT /opt/kafka/bin/kafka-init.sh

ENV PUBLIC_IF=eth0 \
    REPLICATION_IF=eth0 \
    KAFKA_HEAP_OPTS='-Xms384M -Xmx384M' \
    ZK_CLUSTER=127.0.0.1

EXPOSE 9092
USER kafka
