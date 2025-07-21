![screenshot](../6-event-processing-flow-details/event-processing-flow.png)

- [Sample flow that can be imported into IBM Event Processing](./event-processing-flow.json)
- [Definition of the output topic for predictions](./topic.yaml)

**Implementation details:**
- [weather forecasts](../6-event-processing-flow-details/weather-forecasts.sql)
- [extract time info](../6-event-processing-flow-details/extract-time-info.sql)
- [lookup holiday info](../6-event-processing-flow-details/lookup-holiday-info.sql)
- [normalize weather data](../6-event-processing-flow-details/normalize-weather-data.sql)
- [windowed weather](../6-event-processing-flow-details/windowed-weather.sql)
- [bike location updates](../6-event-processing-flow-details/bike-location-updates.sql)
- [count journeys per hour](../6-event-processing-flow-details/count-journeys-by-hour.sql)
- [combine weather with journeys](../6-event-processing-flow-details/combine-weather-with-journeys.sql)
- [collect history](../6-event-processing-flow-details/collect-history.sql)
- [update time](../6-event-processing-flow-details/update-time.sql)
- [granite timeseries forecast](../6-event-processing-flow-details/granite-timeseries-forecast.sql)
- [forecasts](../6-event-processing-flow-details/forecasts.sql)
