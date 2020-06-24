# GOV.UK Ask Export

**⚠️ This repository has been archived following the conclusion of the daily
coronavirus press conferences on the 23rd June 2020.**

A tool for working with the data of the Smart Survey that powers
https://www.gov.uk/ask. This downloads data from Smart Survey, splits it into
CSV files that are shared with recipients and uploads performance analyst data
to Google Big Query.

## Dependencies

To use all the functionality in this project you need a number of third party
services configured:

- [Smart Survey](https://www.smartsurvey.co.uk/) - this project is coded
  to work with a particular survey (and a draft equivalent);
- [Google API](https://developers.google.com/) - this project was designed to
  use a [Service Account](https://cloud.google.com/iam/docs/understanding-service-accounts)
  with API access to Drive and Big Query;
- [GOV.UK Notify](https://www.notifications.service.gov.uk/) - used to notify
  recipients of file access.

Please note, that this project is coded to work directly with particular logins
of these services and wasn't intended to be generic.

## How to use

### Setup

Install dependencies with `bundle install`

### Run tests

```
bundle exec rake
```

This will lint and test the code.

### Daily export

The daily export process is designed to be run once a day after 10am (London
time) from a scheduled task. This task does the following things:

- downloads all of the questions from Smart Survey from 10am the previous day
  until 10am the current day;
- creates CSV files for Cabinet Office, a third-party polling organisation,
  GOV.UK Data Labs, and a performance analyst;
- CSV files are uploaded to Google Drive in the configured directories;
- configured recipients are granted permission to view these files via Google
  Drive;
- configured recipients are sent emails via GOV.UK Notify to provide them with
  a link to the file;
- a table is created in Big Query for the current date and populated with the
  performance analyst data.

The task can be run with:

```
bundle exec rake daily_export
```

The following environment variables should be configured:

- `SMART_SURVEY_LIVE` (optional) - set this to `"true"` to access the live survey,
  otherwise the draft one will be used.
- `SMART_SURVEY_API_TOKEN` - accessible via Smart Survey in Account > API Keys
- `SMART_SURVEY_API_TOKEN_SECRET`
- `GOOGLE_ACCOUNT_TYPE` - expected to be `"service_account"`
- `GOOGLE_CLIENT_ID` - this and following Google fields are populated with
  service account user credentials downloadable from the Google Cloud Platform
  Console
- `GOOGLE_CLIENT_EMAIL`
- `GOOGLE_PRIVATE_KEY`
- `NOTIFY_API_KEY` - API key for the GOV.UK Notify service to inform recipients
  files are ready
- `CABINET_OFFICE_DRIVE_FOLDER` - the file id of the Google Drive folder for
  storing Cabinet Office's CSV exports
- `CABINET_OFFICE_EMAIL_RECIPIENTS` - a comma separated list of email addresses
  of colleagues at the cabinet office who will be emailed upon a successful export
- `DATA_LABS_DRIVE_FOLDER` - the file id of the Google Drive folder for
  storing Data Labs' CSV exports
- `DATA_LABS_EMAIL_RECIPIENTS` - a comma separated list of email addresses
  of colleagues in the Data Labs team who will be emailed upon a successful export
- `PERFORMANCE_ANALYST_DRIVE_FOLDER` - the file id of the Google Drive folder for
  storing CSV exports for performance analysis
- `PERFORMANCE_ANALYST_EMAIL_RECIPIENTS` - a comma separated list of email addresses
  of performance analysts who will be emailed upon a successful export
- `THIRD_PARTY_DRIVE_FOLDER` - the file id of the Google Drive folder for
  storing CSV exports for the third party
- `THIRD_PARTY_EMAIL_RECIPIENTS` - a comma separated list of email addresses
  of third party colleagues who will be emailed upon a successful export
- `SECRET_KEY` - a key that is used as salt to hashing functions to anonymise
  personally identifiable information

### Other tasks

There are a variety of other tasks that available for different specific
situations. They accept the aforementioned daily\_export environment variables
and allow customising the range of the export with the following environment
variables:

- `SINCE_TIME` - defaults to "10:00", can be changed to alter the time
  exports include data from. When this is a relative time (for example "10:00") it
  will be for the previous day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export
- `UNTIL_TIME` - defaults to "10:00", can be changed to alter the time
  exports include data until. When this is a relative time (for example "10:00") it
  will be for the current day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export

#### `bundle exec rake file_export`

This task is used to build CSV file exports on a local machine, thereby
avoiding any integration with Google API and GOV.UK Notify.

Applicable environment variables: `SMART_SURVEY_LIVE`, `SMART_SURVEY_API_TOKEN`,
`SMART_SURVEY_API_TOKEN_SECRET`, `SECRET_KEY`, `SINCE_TIME` and `UNTIL_TIME`.

#### `bundle exec rake drive_export`

This task is used to build and share the CSV files via Google Drive and Notify.
It lacks the Big Query step of the daily export. This task can be used for
exports over a custom time period.

Applicable environment variables are all of the `daily_export` ones with
`SINCE_TIME` and `UNTIL_TIME`.

#### `bundle exec rake big_query_export`

This task is used to download the data and only populate Big Query. This is
useful in situations where you need to backfill Big Query data or fix a failed
Big Query import.

Applicable environment variables: `SMART_SURVEY_LIVE`, `SMART_SURVEY_API_TOKEN`,
`SMART_SURVEY_API_TOKEN_SECRET`, `GOOGLE_ACCOUNT_TYPE`, `GOOGLE_CLIENT_ID`,
`GOOGLE_CLIENT_EMAIL`, `GOOGLE_PRIVATE_KEY`, `SECRET_KEY`, `SINCE_TIME` and
`UNTIL_TIME`.

## Licence

[MIT License](LICENCE)
