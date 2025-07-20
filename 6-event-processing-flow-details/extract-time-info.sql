-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  Break apart the timestamp from the input events into separate
--   properties (e.g. hour, day, month, year), as used by the
--   predictive timeseries model.
-- ----------------------------------------------------------------------

CREATE TEMPORARY VIEW `extract time info` AS
    SELECT
        -- input properties
        `temperature`,
        `type`,
        `humidity`,
        `windSpeed`,
        `time`,

        -- extract numeric properties from the date
        HOUR(`time`)                      AS `hr`,
        DAYOFMONTH(`time`)                AS `day`,
        MONTH(`time`)                     AS `mnth`,
        YEAR(`time`) - 2011               AS `yr`,

        -- string version of the date
        DATE_FORMAT(`time`, 'yyyy-MM-dd') AS `dteday`

    FROM
        `weather forecasts`;
