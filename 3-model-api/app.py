# REST API support
from flask import Flask, request, jsonify
# dependencies used to parse the input JSON data
from json import JSONDecodeError
# dependencies used to create the CSV representation of the input data
from tempfile import NamedTemporaryFile
from csv import writer as csvWriter
from pandas import read_csv, Timedelta
from os import remove
# dependencies used to make timeseries forecasts
from tsfm_public import TimeSeriesForecastingPipeline, TinyTimeMixerForPrediction, TimeSeriesPreprocessor
# error handling
from traceback import print_exc


# initialise the Flask API app
app = Flask(__name__)

# Global pipeline variable
timeseries_pipeline = None

# -----------------------------------------------------------------
# Timeseries model CSV data details
#
#  The timeseries model expects CSV input for forecasting
#  These constants define the CSV structure
# -----------------------------------------------------------------
all_columns = [
    "instant", "dteday", "season", "yr", "mnth", "hr", "holiday",
    "weekday", "workingday", "weathersit", "temp", "atemp", "hum",
    "windspeed", "casual", "registered", "cnt"
]
timestamp_column = "dteday"
target_columns = [ "casual", "registered", "cnt" ]
context_length = 512
prediction_length = 96
batch_size = 64


# called once at startup to load the saved fine-tuned timeseries model
def init_timeseries_model():
    loaded_tsp = TimeSeriesPreprocessor.from_pretrained("model")
    loaded_model = TinyTimeMixerForPrediction.from_pretrained("model")
    return TimeSeriesForecastingPipeline(
        loaded_model,
        device="cpu",
        feature_extractor=loaded_tsp,
        batch_size=batch_size,
    )


# Flink will submit the input data in a single JSON object
#
# Simplest approach to create a dataframe from this is to
#  convert the JSON data into a temporary CSV file, then
#  reuse existing implementation for creating dataframes
#  from CSV files
def convert_json_to_dataframe(input_json_data):
    # Initialize output CSV rows
    csvRows = []

    # Create each CSV row from the input JSON data
    for idx, item in enumerate(reversed(input_json_data["history"]), start=1):
        nextRow = [idx]
        for column in all_columns[1:]:
            nextRow.append(item.get(column, ""))
        csvRows.append(nextRow)

    # Write to a temporary CSV file - which will be
    #  deleted once the dataframe has been created from it
    temp_csv = NamedTemporaryFile(delete=False, suffix=".csv")
    try:
        with open(temp_csv.name, 'w', newline='') as f:
            writer = csvWriter(f)
            writer.writerow(all_columns)
            writer.writerows(csvRows)
        input_df = read_csv(temp_csv.name, parse_dates=[timestamp_column])

        # update the timestamp column so that it combines the
        #  date and hour values to make a complete timestamp
        input_df[timestamp_column] = input_df[timestamp_column] + input_df.hr.apply(lambda x: Timedelta(x, unit="hr"))

        # compute the cnt column by summing the casual and registered journeys
        input_df["cnt"] = input_df["casual"] + input_df["registered"]

        # return the pre-processed dataframe
        return input_df
    finally:
        # cleanup temporary CSV file
        remove(temp_csv.name)



@app.route('/', methods=['GET'])
def probe():
    return jsonify({ "ok": True })



@app.route('/forecast', methods=['POST'])
def forecast():
    global timeseries_pipeline
    app.logger.info("Handling forecast request")

    with NamedTemporaryFile(delete=False, suffix=".csv") as temp_csv:
        csv_output = temp_csv.name

    try:
        json_input = request.get_json()

        df_input = convert_json_to_dataframe(json_input)

        forecast = timeseries_pipeline(df_input)

        HOURS_TO_FORECAST = 12
        return jsonify({
            "forecast": [
                {
                    "casual"     : int(forecast["casual_prediction"][0][hour]),
                    "registered" : int(forecast["registered_prediction"][0][hour]),
                    "cnt"        : int(forecast["cnt_prediction"][0][hour])
                }
                for hour in range(HOURS_TO_FORECAST)
            ]
        })
    except JSONDecodeError:
        return jsonify({ "error": "Invalid input"}), 400
    except Exception as e:
        print_exc()
        return jsonify({ "error": str(e) }), 500
    finally:
        remove(csv_output)



app.logger.info("Loading model")
timeseries_pipeline = init_timeseries_model()
app.logger.info("Model loaded")


if __name__ == '__main__':
    app.run()
