# GOV.UK Ask Export

A tool for working with the data of the Smart Survey that powers
https://www.gov.uk/ask. This downloads data from Smart Survey and splits
this data into CSV files. These can then be distributed manually with
recipients.

This was once a [bigger project][remove-pr] which ran an automated daily task
using Concourse. This process automatically distributed files to Google Drive,
notified users via GOV.UK Notify and populated a database in Google Big Query.
This was retired when the UK Governments daily coronavirus press conferences
ended.

[remove-pr]: https://github.com/alphagov/govuk-ask-export/pull/17

## Dependencies

To use all the functionality in this project you will need access to the
GOV.UK [Smart Survey](https://www.smartsurvey.co.uk/) account. The
credentials are available in [govuk-secrets][].

[govuk-secrets]: https://github.com/alphagov/govuk-secrets

## How to use

### Setup

Install dependencies with `bundle install`

### Run tests

```
bundle exec rake
```

This will lint and test the code.

### Run a file export

Running a file export downloads data from Smart Survey and outputs 4 different
CSV files intended for different audiences. These are:

- Third party polling organisation - they receive question ids and the
  questions themselves, without any personal information. It is intended to be
  used for determining which questions are used in conferences.
- Cabinet Office - they receive question ids and personal information of
  question submitters, they do not receive questions. It is used to provide
  necessary contact information to contact question submitters.
- Data Labs - they receive questions submitted and hashed versions of email
  addresses and phone numbers to help detect duplicate. Data Labs are expected
  to run the questions through a personally identifiable information removal
  tool before analysis
- Performance Analyst - they receive data on the access to the service and
  completion rates, which can be used to determine success rates and user
  journeys.

The task can be run with:

```
bundle exec rake file_export
```

The following environment variables should be configured for the task:

- `SMART_SURVEY_CONFIG` (optional) - set this to `"live"` to access the live survey,
  otherwise the draft one will be used.
- `SMART_SURVEY_API_TOKEN` - accessible via Smart Survey in Account > API Keys
- `SMART_SURVEY_API_TOKEN_SECRET`
- `SECRET_KEY` - a key that is used as salt to hashing functions to anonymise
  personally identifiable information
- `SINCE_TIME` - defaults to "10:00", can be changed to alter the time
  exports include data from. When this is a relative time (for example "10:00") it
  will be for the previous day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export
- `UNTIL_TIME` - defaults to "10:00", can be changed to alter the time
  exports include data until. When this is a relative time (for example "10:00") it
  will be for the current day, otherwise an absolute time can be set (for example
  "2020-05-01 10:00") for a precise data export

Example:

```
SMART_SURVEY_CONFIG=live SINCE_TIME=09:00 UNTIL_TIME=11:00 SECRET_KEY=$(openssl rand -hex 64) SMART_SURVEY_API_TOKEN=<api-token> SMART_SURVEY_API_TOKEN_SECRET=<api-token-secret> bundle exec rake file_export
```

## Licence

[MIT License](LICENCE)
