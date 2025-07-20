CREATE TEMPORARY VIEW `windowed weather` AS
    SELECT
        *
    FROM
        TABLE (
            TUMBLE( TABLE `normalize weather data`,
                    DESCRIPTOR(`time`),
                    INTERVAL '1' HOUR )
        );
