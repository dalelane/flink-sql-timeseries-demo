CREATE TABLE `weather forecasts___TABLE`
(
    `temperature`                  ROW<`reading` DOUBLE, `feelslike` DOUBLE>,
    `type`                         ROW<`description` STRING, `code` BIGINT>,
    `humidity`                     BIGINT,
    `windSpeed`                    DOUBLE,
    `time`                         STRING,
    `time___EVENT_TIME`            AS CAST (TO_TIMESTAMP_UDF(`time`) AS TIMESTAMP(3)),
    WATERMARK FOR `time___EVENT_TIME` AS `time___EVENT_TIME` - INTERVAL '3' SECOND
)
WITH (
    'format' = 'json',
    'json.ignore-parse-errors' = 'true',
    'scan.startup.mode' = 'earliest-offset',
    'connector' = 'kafka',
    'topic' = 'BIKESHARING.WEATHER',
    'properties.bootstrap.servers' = 'my-kafka-cluster-kafka-bootstrap.event-automation.svc:9095',
    'properties.sasl.mechanism' = 'SCRAM-SHA-512',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.ssl.truststore.type' = 'PEM',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.scram.ScramLoginModule required username="kafka-demo-apps" password="kafka-demo-apps-password";',
    'properties.ssl.endpoint.identification.algorithm' = '',
    'properties.isolation.level' = 'read_committed'
);

CREATE TEMPORARY VIEW `weather forecasts` AS
    SELECT
        `temperature`                  AS `temperature`,
        `type`                         AS `type`,
        `humidity`                     AS `humidity`,
        `windSpeed`                    AS `windSpeed`,
        `time___EVENT_TIME`            AS `time`
    FROM
        `weather forecasts___TABLE`;
