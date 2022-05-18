ARG DOCKER_TAG=7.0.1

FROM confluentinc/cp-kafka-connect:${DOCKER_TAG}

ARG KAFKA_CONNECT_MQTT_VERSION=3.0.1-2.5.0 DEBEZIUM_VERSION=1.8.1 RABBITMQ_CONNECT_VERSION=0.1.0

USER root

RUN cd /tmp && \
    yum -y -q install git maven java-1.8.0-openjdk-devel && \
    git clone -b ${RABBITMQ_CONNECT_VERSION} https://github.com/trezorg/kafka-connect-rabbitmq && \
    cd kafka-connect-rabbitmq && \
    mvn install && \
    tar -xf target/kafka-connect-rabbitmq-${RABBITMQ_CONNECT_VERSION}.tar.gz && \
    cp -v usr/share/kafka-connect/kafka-connect-rabbitmq/*.jar /usr/share/java/kafka && \
    yum -y -q remove git maven java-1.8.0-openjdk-devel

RUN export KAFKA_CONNECT_MQTT_SUBVERSION=$(cut -d- -f 1 <<<"${KAFKA_CONNECT_MQTT_VERSION}") && \
    cd /tmp && \
    curl -sSLo /tmp/kafka-connect-mqtt-${KAFKA_CONNECT_MQTT_VERSION}-all.tar.gz https://github.com/lensesio/stream-reactor/releases/download/${KAFKA_CONNECT_MQTT_SUBVERSION}/kafka-connect-mqtt-${KAFKA_CONNECT_MQTT_VERSION}-all.tar.gz && \
    tar -xf /tmp/kafka-connect-mqtt-${KAFKA_CONNECT_MQTT_VERSION}-all.tar.gz && \
    curl -sSLo /tmp/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz \
    https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}.Final/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz && \
    tar -xf /tmp/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz && \
    cp -v /tmp/kafka-connect-mqtt-${KAFKA_CONNECT_MQTT_VERSION}-all.jar /usr/share/java/kafka && \
    cp -v debezium-connector-postgres/*.jar /usr/share/java/kafka && \
    rm -rf /tmp/*

USER appuser
