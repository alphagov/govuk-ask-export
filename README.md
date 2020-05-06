# GOV.UK Ask Export

A tool for working with the data of the Smart Survey that powers
https://www.gov.uk/ask. This downloads data from Smart Survey, splits it into
CSV files, uploads those to S3 and then sends notifications to recipients.

## How to use

### Run tests

```
bundle install
bundle exec rake
```

### Daily export

The daily export process is designed to be run once a day after 10am (London
time) from a scheduled task. This is not currently set-up.

The task can be run with:

```
bundle exec rake export
```

The following environment variables 



### Manual CSV split

If the daily export cannot be run or fails we have a manual process can than
be followed to generate the necessary CSV files.

The first step is create an export in Smart Survey and download the file

1. Log into https://www.smartsurvey.co.uk and select the appropriate survey
1. Click on Results, then go to Export
1. Name your export for the day you are exporting, select the Raw Response Data
   option and choose the CSV format
  - Click on the customise section
    - In the options tab ensure that "Include respondant details" is turned on
    - In the appearance tab change the "Column heading style" to be "Display
      Question ID's - E.g. Q1001, Q1002..."
  - In the filters tab:
    - Turn on "Select custom filter" and choose "Completed Over 18 Responses"
    - Go to the "Date range" field and select "Custom range" then adjust
      the "From" time to be 10am on the previous day and the "To" time to
      be 10am on the current day
1. Click "Export" and wait for the report to be generated, then click the
   download link to save the file

Once you have the file downloaded, run the following command:

```
CSV_FILE=/path/to/file.csv bundle exec rake split_csv_export
```

There should now be files created in the `output` directory of this project
that can be shared.

## Licence

[MIT License](LICENCE)
