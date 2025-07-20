-- ----------------------------------------------------------------------
-- OVERVIEW:
--
--  Journeys are represented as multiple events - capturing the location
--   of the bike at various points during the journey.
--
--   This counts the number of unique journey IDs in each hour to
--    provide a high-level per-hour summary of journey activity.
-- ----------------------------------------------------------------------
-- THE OUTPUT FROM THIS NODE IS:
--
--  window_start
--  window_end
--  window_time
--  casual        (NULL or the number of journeys in the hour starting from `hour` where usertype=CASUAL)
--  registered    (NULL or the number of journeys in the hour starting from `hour` where usertype=REGISTERED)
--  heartbeat     (NULL or the number of journeys in the hour starting from `hour` where usertype=HEARTBEAT)
-- ----------------------------------------------------------------------

CREATE TEMPORARY VIEW `count journeys per hour` AS
        SELECT
            `window_start`,
            `window_end`,
            `window_time`,

            COUNT(DISTINCT CASE WHEN `usertype` = 'CASUAL'     THEN `journeyid` END) AS casual,
            COUNT(DISTINCT CASE WHEN `usertype` = 'REGISTERED' THEN `journeyid` END) AS registered,

            -- HEARTBEAT doesn't represent real journey data - these are emitted at the start of every
            --  hour to ensure that there is not a delay in closing the tumbling window if there are
            --  no other journey events at the start of an hour
            COUNT(DISTINCT CASE WHEN `usertype` = 'HEARTBEAT'  THEN `journeyid` END) AS heartbeat
        FROM
            TABLE (
                TUMBLE( TABLE `bike location updates`,
                        DESCRIPTOR(`time`),
                        INTERVAL '1' HOUR )
            )
        GROUP BY
            `window_start`,
            `window_end`,
            `window_time`;
