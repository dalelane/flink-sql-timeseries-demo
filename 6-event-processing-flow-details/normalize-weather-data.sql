-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  The timeseries model uses a scaled version of weather data.
--   This applies the scaling to the input weather readings.
-- ----------------------------------------------------------------------

CREATE TEMPORARY VIEW `normalize weather data` AS
    SELECT
        -- timestamp
        `time`,

        -- input time-related properties
        `dteday`,
        `yr`,
        `mnth`,
        `hr`,
        `holiday`,
        `workingday`,

        -- convert the day-of-week to the format expected by the model
        DAYOFWEEK(`time`) - 1          AS `weekday`,

        -- use the date properties to decide what season the day is in
        CASE
            WHEN (`mnth` = 3 AND `day` >= 21) OR
                (`mnth` IN (4, 5)) OR
                (`mnth` = 6 AND `day` <= 20)
                THEN 2
            WHEN (`mnth` = 6 AND `day` >= 21) OR
                (`mnth` IN (7, 8)) OR
                (`mnth` = 9 AND `day` <= 22)
                THEN 3
            WHEN (`mnth` = 9 AND `day` >= 23) OR
                (`mnth` IN (10, 11)) OR
                (`mnth` = 12 AND `day` <= 20)
                THEN 4
            ELSE 1
        END                            AS `season`,

        -- weather data - renamed and normalized to meet model requirements
        type.code                      AS `weathersit`,
        temperature.reading / 41       AS `temp`,
        temperature.feelslike / 50     AS `atemp`,
        CAST(humidity AS DOUBLE) / 100 AS `hum`,
        windSpeed / 67                 AS `windspeed`
    FROM
        `lookup holiday info`;
