# Using a time series model with Apache Kafka and Apache Flink using IBM Event Automation

An example project illustrating how a time series model can be invoked from a Flink SQL job, showing how to set this up using IBM Event Automation.

## Contents

- **[dataset](./0-dataset/)**
    - the data set used in this example
- **[Kafka data source](./1-kafka-data-source/)**
    - creating Kafka topics with live streams of events based on the data set
- **[time series model](./2-timeseries-model/)**
    - creating a custom fine tuned time series model based on the data set
- **[time series model API](./3-model-api/)**
    - a REST API for making predictions using the time series model
- **[holidays database](./4-holidays-database/)**
    - a database for looking up if a given date is a holiday
- **Flink SQL job**
    - [creating a job in the Event Processing canvas](./5-event-processing-flow/)
    - [details of the Flink SQL created in the canvas](./6-event-processing-flow-details/)
