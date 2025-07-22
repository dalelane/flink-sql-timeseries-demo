-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  Submit the recent history of bike journeys to the time series model
--   and receive the forecast for the predicted number of journeys in the
--   next four days.
--
--  The time series model is hosted in a custom Python docker image that
--   is a simplified representation of hosting a custom model in watsonx.ai
--
--  The model is invoked by a REST API using the flink-http-connector
--   from https://github.com/getindata/flink-http-connector
-- ----------------------------------------------------------------------

CREATE TEMPORARY VIEW `granite timeseries forecast_update time__API` AS
    SELECT
        *,
        PROCTIME()                     AS `proc_time`
    FROM
        `update time`;

    CREATE TEMPORARY TABLE `granite timeseries forecast_lookup__API`
    (
        `requestBody_history`          ARRAY<ROW<`dteday` STRING, `season` INT, `yr` INT, `mnth` INT, `hr` INT, `holiday` INT, `weekday` INT, `workingday` INT, `weathersit` INT, `temp` DOUBLE, `atemp` DOUBLE, `hum` DOUBLE, `windspeed` DOUBLE, `casual` INT, `registered` INT>>,
        `response_forecast`            ARRAY<ROW<`casual` DOUBLE, `cnt` DOUBLE, `registered` DOUBLE>>
    )
    WITH (
        'connector' = 'rest-lookup',
        'url' = 'http://timeseries:5000/forecast',
        'lookup-method' = 'POST',
        'gid.connector.http.source.lookup.header.Accept' = 'application/json',
        'format' = 'gid.connector.http.response-json',
        'gid.connector.http.source.lookup.request-callback' = 'rest-lookup-logger',
        'gid.connector.http.source.lookup.request.thread-pool.size' = '32',
        'asyncPolling' = 'true',
        'gid.connector.http.source.lookup.query-creator' = 'templated-query',
        'gid.connector.http.source.lookup.request.timeout' = '30',
        'gid.connector.http.request-arg-paths' = '{"requestBody_history":"history"}',
        'gid.connector.http.source.lookup.header.Origin' = '*',
        'gid.connector.http.source.lookup.header.X-Content-Type-Options' = 'nosniff',
        'gid.connector.http.response-json.arg-paths' = '{"requestBody_history":"history","response_forecast":"forecast"}',
        'gid.connector.http.source.lookup.header.Content-Type' = 'application/json',
        'gid.connector.http.source.lookup.response.thread-pool.size' = '16'
    );

CREATE TEMPORARY VIEW `granite timeseries forecast` AS
    SELECT
        `granite timeseries forecast_update time__API`.`time`         AS `time`,
        `granite timeseries forecast_update time__API`.`history`      AS `history`,
        `granite timeseries forecast_lookup__API`.`response_forecast` AS `forecast`
    FROM
        `granite timeseries forecast_update time__API`
    JOIN
        `granite timeseries forecast_lookup__API`
            FOR SYSTEM_TIME AS OF `granite timeseries forecast_update time__API`.`proc_time`
        ON
            `granite timeseries forecast_lookup__API`.`requestBody_history`=`granite timeseries forecast_update time__API`.`history`;
