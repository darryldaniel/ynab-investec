# YNAB Investec

> A Rails app for connecting YNAB to Investec

## Features

### Card transaction entry in YNAB
Processes card transactions and sends them to YNAB. You can then edit the details in YNAB as needed.

### Automatic transaction sync
Pulls in transactions for the last 7 days and sends it YNAB. YNAB auto-links transactions from card transactions
previously entered. Uses [cronitor](https://cronitor.io/) to monitor the sync and alert if it fails.

### Automatic transaction merchant mapping
Every merchant will have different names depending on where you purchase from.
When an Investec card transaction comes in, check against the existing merchants if any of them are mapped to a YNAB id.
If it is, send through the id so that the correct merchant is set on YNAB’s side.

## Development setup

### Environment variables
All base environment variables for dev are stored in `.env.development`. Do not add sensitive variables to this file.
Instead, create a `.env.development.local` file and add the sensitive variables there. This file is ignored by git.

#### Investec Credentials
The best guide for getting your Investec api key, client id and client secret is
[here](https://investec.gitbook.io/programmable-banking-community-wiki/get-started/api-quick-start-guide/how-to-get-your-api-keys).
Follow the guide and then populate `.env.development.local` with the following:
```dotenv
INVESTEC_API_KEY=
INVESTEC_CLIENT_ID=
INVESTEC_CLIENT_SECRET=
```

#### YNAB Credentials
Follow the guide [here](https://api.ynab.com/) to get your YNAB access token.
Then populate `.env.development.local` with the following:
```dotenv
YNAB_ACCESS_TOKEN=
```

### Create the database user
Run the following in MySQL:
```mysql
create user 'banking'@'localhost' identified by 'banking';
grant all privileges on banking_development.* to 'banking'@'localhost' with grant option;
grant all privileges on banking_test.* to 'banking'@'localhost' with grant option;
flush privileges;
```
The username and password for the users can be overridden in `.env.development.local`.

### Run setup script
Run `bin/setup` to install dependencies, create the database and run migrations.

### Add accounts and cards to the database
The accounts table requires the account number (usually shown to the client) and the investec account id.
To get this ID, make an api call to the investec api. You can do this through the rails console with `rails c`.

The cards table requires the card number (shown on the front of the card) and the investec card id.
To get this, simulate a transaction in the investec app and take note of the card id returned.

This app also needs the linked ynab account id. You can get this by navigating to the account in YNAB and getting
the guid at the end of the url ie:
`https://app.ynab.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/accounts/yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy`
where the guid is `yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy`. Also note that your budget id would be
`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` which you can add to your environment variables in `.env.development.local`.
