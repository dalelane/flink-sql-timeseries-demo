CREATE TEMPORARY VIEW `collect history` AS
    SELECT
        MAX(`time`) AS `time`,
        ARRAY_AGG(
            CAST(
                ROW(`dteday`, `season`,
                        `yr`, `mnth`, `hr`,
                        `holiday`, `weekday`, `workingday`,
                        `weathersit`, `temp`, `atemp`, `hum`, `windspeed`,
                        `casual`, `registered`)
                    AS
                ROW<`dteday` STRING, `season` INT,
                        `yr` INT, `mnth` INT, `hr` INT,
                        `holiday` INT, `weekday` INT, `workingday` INT,
                        `weathersit` INT, `temp` DOUBLE, `atemp` DOUBLE, `hum` DOUBLE, `windspeed` DOUBLE,
                        `casual` INT, `registered` INT>
            )
        ) AS `history`
    FROM TABLE (
        HOP( TABLE `combine weather with journeys`,
                DESCRIPTOR(`journeys_window_time`),
                INTERVAL '1' HOUR,
                INTERVAL '4' DAYS )
    )
    GROUP BY
        `window_start`,
        `window_end`,
        `window_time`;
