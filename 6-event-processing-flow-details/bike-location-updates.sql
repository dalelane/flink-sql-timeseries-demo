CREATE TABLE `bike location updates___TABLE`
(
    `journeyid`                    STRING,
    `bikeid`                       STRING,
    `usertype`                     STRING,
    `location`                     ROW<`latitude` DOUBLE, `longitude` DOUBLE>,
    `battery`                      BIGINT,
    `time`                         STRING,
    `time___EVENT_TIME`            AS CAST (TO_TIMESTAMP_UDF(`time`) AS TIMESTAMP(3)),
    WATERMARK FOR `time___EVENT_TIME` AS `time___EVENT_TIME` - INTERVAL '3' SECOND
)
WITH (
    'format' = 'json',
    'json.ignore-parse-errors' = 'true',
    'scan.startup.mode' = 'earliest-offset',
    'connector' = 'kafka',
    'topic' = 'BIKESHARING.LOCATION',
    'properties.bootstrap.servers' = 'my-kafka-cluster-kafka-bootstrap.event-automation.svc:9095',
    'properties.sasl.mechanism' = 'SCRAM-SHA-512',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.ssl.truststore.type' = 'PEM',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.scram.ScramLoginModule required username="kafka-demo-apps" password="Q4rDF9WYysKFmyamZgHhXERLT1VccPat";',
    'properties.ssl.endpoint.identification.algorithm' = '',
    'properties.isolation.level' = 'read_committed'
);

CREATE TEMPORARY VIEW `bike location updates` AS
    SELECT
        `journeyid`                    AS `journeyid`,
        `bikeid`                       AS `bikeid`,
        `usertype`                     AS `usertype`,
        `location`                     AS `location`,
        `battery`                      AS `battery`,
        `time___EVENT_TIME`            AS `time`
    FROM
        `bike location updates___TABLE`;
