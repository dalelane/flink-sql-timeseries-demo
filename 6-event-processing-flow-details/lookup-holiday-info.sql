-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  Enrich the events so that dates in the events are supplemented with
--   additional information about the date from a holidays database.
--   This will identify whether the date is a public holiday and if it
--   was a working day or not.
-- ----------------------------------------------------------------------

CREATE TEMPORARY TABLE `bikesharingcalendar_database`
(
    `day`                          INT,
    `mnth`                         INT,
    `yr`                           INT,
    `originalyear`                 INT,
    `holiday`                      INT,
    `weekday`                      INT,
    `workingday`                   INT
)
WITH (
    'password' = '=lN{a5aag?wsUn)5>cTI0F{-',
    'connector' = 'jdbc',
    'table-name' = 'bikesharingcalendar',
    'url' = 'jdbc:postgresql://pgsqldemo-primary.event-automation.svc:5432/pgsqldemo',
    'username' = 'demouser',

    'lookup.cache' = 'PARTIAL',
    'lookup.partial-cache.max-rows' = '7'
);


CREATE TEMPORARY VIEW `extract time info with proctime` AS
    SELECT
        *,
        PROCTIME() AS `proc_time`
    FROM
        `extract time info`;


CREATE TEMPORARY VIEW `lookup holiday info` AS
    SELECT
        -- time properties from the events
        `extract time info with proctime`.`dteday`      AS `dteday`,
        `extract time info with proctime`.`time`        AS `time`,
        `extract time info with proctime`.`hr`          AS `hr`,
        `extract time info with proctime`.`day`         AS `day`,
        `extract time info with proctime`.`mnth`        AS `mnth`,
        `extract time info with proctime`.`yr`          AS `yr`,
        -- weather info from the events
        `extract time info with proctime`.`temperature` AS `temperature`,
        `extract time info with proctime`.`type`        AS `type`,
        `extract time info with proctime`.`humidity`    AS `humidity`,
        `extract time info with proctime`.`windSpeed`   AS `windSpeed`,
        -- data looked up from the database
        `bikesharingcalendar_database`.`holiday`        AS `holiday`,
        `bikesharingcalendar_database`.`workingday`     AS `workingday`

    FROM
        `extract time info with proctime`
    LEFT JOIN
        `bikesharingcalendar_database`
            FOR SYSTEM_TIME AS OF `extract time info with proctime`.`proc_time`
        ON
            CAST(`extract time info with proctime`.`day` AS INTEGER)  = `bikesharingcalendar_database`.`day`
                AND
            CAST(`extract time info with proctime`.`mnth` AS INTEGER) = `bikesharingcalendar_database`.`mnth`
                AND
            0  = `bikesharingcalendar_database`.`yr`;
