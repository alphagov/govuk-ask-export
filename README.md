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
