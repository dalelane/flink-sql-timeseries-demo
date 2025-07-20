CREATE TEMPORARY VIEW `update time` AS
    SELECT
        `history`                      AS `history`,
        TIMESTAMPADD(HOUR, 1, `time`)  AS `time`
    FROM
        `collect history`;
