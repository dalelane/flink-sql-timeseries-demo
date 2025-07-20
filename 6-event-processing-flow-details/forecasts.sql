CREATE TABLE `forecasts`
(
    `time`        TIMESTAMP(9) METADATA FROM 'timestamp',
    `history`     ARRAY<ROW<`dteday` STRING, `season` INT, `yr` INT, `mnth` INT, `hr` INT, `holiday` INT, `weekday` INT, `workingday` INT, `weathersit` INT, `temp` DOUBLE, `atemp` DOUBLE, `hum` DOUBLE, `windspeed` DOUBLE, `casual` INT, `registered` INT>>,
    `forecast`    ARRAY<ROW<`casual` DOUBLE, `cnt` DOUBLE, `registered` DOUBLE>>
)
WITH (
    'format' = 'json',
    'connector' = 'kafka',
    'topic' = 'BIKESHARING.PREDICTIONS',
    'properties.bootstrap.servers' = 'my-kafka-cluster-kafka-bootstrap.event-automation.svc:9095',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.scram.ScramLoginModule required username="kafka-demo-apps" password="kafka-demo-apps-password";',
    'properties.sasl.mechanism' = 'SCRAM-SHA-512',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.ssl.endpoint.identification.algorithm' = '',
    'properties.ssl.truststore.type' = 'PEM'
);