# GOV.UK Ask Export

A tool for working with the data of the Smart Survey that powers
https://www.gov.uk/ask. This downloads data from Smart Survey and splits it into
CSV files.

## How to use

### Setup

Install dependencies with `bundle install`

### Run tests

```
bundle exec rake
```

This will lint and test the code.

### Daily Google Drive export

The daily export process is designed to be run once a day after 10am (London
time) from a scheduled task. This is not currently set-up.

The task can be run with:

```
bundle exec rake drive_export
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
- `SINCE_TIME` (optional) - defaults to "10:00", can be changed to alter the time
  exports include data from. When this is a relative time (for example "10:00") it
  will be for the previous day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export
- `UNTIL_TIME` (optional) - defaults to "10:00", can be changed to alter the time
  exports include data until. When this is a relative time (for example "10:00") it
  will be for the current day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export

### Manual export

If the daily export cannot be run or fails we have a manual process that can
be run on a local machine to generate the CSV files. This can also be used
to handle requests for ad-hoc time periods.

You'll need the API token and API Token Secret for Smart Survey which can be
found in the Account > API Keys section.

You can test a draft export with:

```
SMART_SURVEY_API_TOKEN=<api-token> SMART_SURVEY_API_TOKEN_SECRET=<api-token-secret> bundle exec rake file_export
```

There should now be files created in the `output` directory of this project
that can be shared.

You can specify the time range the export should run from and until with the
`SINCE_TIME` and `UNTIL_TIME` environment variables. It is recommended you
use ISO 8601 formatting such as "2020-05-01 10:00" or "10:00"

For example:

```
SINCE_TIME=09:00 UNTIL_TIME=11:00 SMART_SURVEY_API_TOKEN=<api-token> SMART_SURVEY_API_TOKEN_SECRET=<api-token-secret> bundle exec rake file_export
```

To perform the live export you need `SMART_SURVEY_LIVE` to equal `"true"`, for
example:

```
SMART_SURVEY_LIVE=true SINCE_TIME=09:00 UNTIL_TIME=11:00 SMART_SURVEY_API_TOKEN=<api-token> SMART_SURVEY_API_TOKEN_SECRET=<api-token-secret> bundle exec rake file_export
```

This should now have added files to the `output` directory (it will have
overwritten any draft files).

## Licence

[MIT License](LICENCE)
