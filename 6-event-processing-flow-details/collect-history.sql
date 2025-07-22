-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  The time series model will need the recent history of bike journeys
--   in order to make a forecast of the expected journeys in the coming
--   hours.
--
--  The model being used (based on fine-tuning 512-96-ft-r2.1) can
--   forecast the number of journeys for the next 96 hours (4 days)
--   if given the data for up to the last 512 hours (> 21 days)
--   cf. https://huggingface.co/ibm-research/ttm-research-r2
--
--  This step collects hourly journeys data for the last 21 days.
-- ----------------------------------------------------------------------

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
                INTERVAL '21' DAYS )
    )
    GROUP BY
        `window_start`,
        `window_end`,
        `window_time`;
