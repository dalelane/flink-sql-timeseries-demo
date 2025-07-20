CREATE TEMPORARY VIEW `combine weather with journeys` AS
    SELECT
        --
        `windowed weather`.`time` AS `time`,
        `windowed weather`.`dteday` AS `dteday`,
        `windowed weather`.`season` AS `season`,
        `windowed weather`.`yr`  AS `yr`,
        `windowed weather`.`mnth` AS `mnth`,
        `windowed weather`.`hr`  AS `hr`,
        `windowed weather`.`holiday` AS `holiday`,
        `windowed weather`.`weekday` AS `weekday`,
        `windowed weather`.`workingday` AS `workingday`,
        `windowed weather`.`weathersit` AS `weathersit`,
        `windowed weather`.`temp` AS `temp`,
        `windowed weather`.`atemp` AS `atemp`,
        `windowed weather`.`hum` AS `hum`,
        `windowed weather`.`windspeed` AS `windspeed`,

        --
        `count journeys per hour`.window_start AS journeys_window_start,
        `count journeys per hour`.window_end AS journeys_window_end,
        `count journeys per hour`.window_time AS journeys_window_time,
        COALESCE( `count journeys per hour`.`casual`, 0 ) AS `casual`,
        COALESCE( `count journeys per hour`.`registered`, 0 ) AS `registered`

    FROM
        `count journeys per hour`

    JOIN
        `windowed weather`

    ON
        `windowed weather`.`window_start` = `count journeys per hour`.`window_start`
            AND
        `windowed weather`.`window_end` = `count journeys per hour`.`window_end`;
