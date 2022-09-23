# GOV.UK Ask Export

A tool for exporting the user responses and metadata from Smart Survey which is
used for the https://www.gov.uk/ask service. This does the following:

- downloads data from Smart Survey API
- removes identifying strings from the user's question text
- formats the data in CSV file
- exports the CSV file to specified targets including to the local filesystem,
  a Google Drive folder or an AWS S3 bucket

A [Jenkins job][] has been configured to run daily, to export the previous
day's smart survey data. However, this project can also be run manually on your
local machine if needed.

[Jenkins job]: https://github.com/alphagov/govuk-puppet/blob/main/modules/govuk_jenkins/templates/jobs/ask_export.yaml.erb

## Dependencies

This project has several external dependencies and needs access to the
following credentials:

- GOV.UK's [Smart Survey](https://www.smartsurvey.co.uk/) account. The
  credentials are available in [govuk-secrets][].
- Google Cloud Platform Service Account with appropriate permissions, DLP and
  Google Drive APIs enabled and billing enabled. This is used to remove
  identifiable strings and to export files to Google Drive
- AWS IAM User credentials to export files to an S3 bucket.

[govuk-secrets]: https://github.com/alphagov/govuk-secrets

## How to use

### Setup

Install dependencies with `bundle install`

### Configure the exports

The exports are configured in
[`config/pipelines.yml`](https://github.com/alphagov/govuk-ask-export/blob/master/config/pipelines.yml).
Each pipeline represents a version of the CSV data being generated. Pipelines
are configured to export specific data fields or CSV columns listed under `fields`
attribute. Each pipeline can specify zero or more export targets under the
`targets` attribute. These are the names of the locations to which the file
should be exported to.

### Set the environment variables

The following environment variables should be configured:

| Environment Variable Key       | Description                                                                                                                                                                                                                            |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SMART_SURVEY_CONFIG            | This configures which Smart Survey to retrieve data from. Defaults to `draft`. Set to `live` for the live survey.                                                                                                          |
| SMART_SURVEY_API_TOKEN         | Credentials found in Smart Survey, under Account > API Keys. (Required)                                                                                                                                                                |
| SMART_SURVEY_API_TOKEN_SECRET  | Credentials found in Smart Survey, under Account > API Keys. (Required)                                                                                                                                                                |
| SINCE_TIME                     | Retrieve responses submitted after this time. Can be set as a time (e.g. "13:00") for the previous day or can be set as a datetime (e.g. "2020-05-01 10:00") to specify the date. Default is "10:00".                        |
| UNTIL_TIME                     | Retrieve responses submitted before this time. Can be set as a time (e.g. "13:00") for the current day or can be set as a datetime (e.g. "2020-05-01 16:00") to specify the date. Default is "10:00".                        |
| FOLDER_ID_<PIPELINE_NAME>      | Each pipeline with an export target `google_drive` requires an environment variable to be set. This specifies the Google Drive folder to export to for that pipeline. E.g. `cabinet-office` needs `FOLDER_ID_CABINET_OFFICE` set.      |
| GOOGLE_CLOUD_PROJECT           | The GCP project name which has the billing and DLP API enabled.                                                                                                                                                                        |
| GOOGLE_ACCOUNT_TYPE            | The account type for the credentials used by Google APIs. This should be `service_account`.                                                                                                                                            |
| GOOGLE_CLIENT_ID               | GCP credentials for the service account.                                                                                                                                                                                               |
| GOOGLE_CLIENT_EMAIL            | GCP credentials for the service account.                                                                                                                                                                                               |
| GOOGLE_PRIVATE_KEY             | GCP credentials for the service account.                                                                                                                                                                                               |

Then run the rake task:

```
bundle exec rake run_exports
```

To run existing pipeline:

```
SINCE_TIME=00:00 \
UNTIL_TIME=00:00 \
SMART_SURVEY_API_TOKEN=<smart-survey-api-token> \
SMART_SURVEY_API_TOKEN_SECRET=<smart-survey-api-token-secret> \
SMART_SURVEY_CONFIG=live \
GOOGLE_ACCOUNT_TYPE=service_account \
GOOGLE_CLIENT_ID=<google-client-id> \
GOOGLE_CLIENT_EMAIL=<google-client-email> \
GOOGLE_PRIVATE_KEY=<google-private-key> \
GOOGLE_CLOUD_PROJECT=<google-cloud-project> \
FOLDER_ID_CABINET_OFFICE=<google-drive-folder-id-cabinet-office> \
FOLDER_ID_THIRD_PARTY=<google-drive-folder-id-third-party> \
bundle exec rake run_exports
```

Minimal configuration to run would be:

```
SINCE_TIME=09:00 \
UNTIL_TIME=11:00\
SMART_SURVEY_CONFIG=live \
SMART_SURVEY_API_TOKEN=<api-token> \
SMART_SURVEY_API_TOKEN_SECRET=<api-token-secret> \
GOOGLE_CLOUD_PROJECT=<project-name> \
GOOGLE_ACCOUNT_TYPE=service_account \
GOOGLE_CLIENT_ID=<client-id> \
GOOGLE_CLIENT_EMAIL=<service-account-email> \
GOOGLE_PRIVATE_KEY=<private-key> \
bundle exec rake run_exports
```

## Development

### Run tests

```
bundle exec rake
```

This will lint and test the code.

## Licence

[MIT License](LICENCE)
