# YNAB Investec

> A Rails app for connecting YNAB to Investec

## Development setup
### Create the database user
Run the following in MySQL:
```mysql
create user 'banking'@'localhost' identified by 'banking';
grant all privileges on banking_development.* to 'banking'@'localhost' with grant option;
grant all privileges on banking_test.* to 'banking'@'localhost' with grant option;
flush privileges;
```
The username and password is supplied in the `env.development` and `env.test` files.
To override these, create a `env.development.local` and `env.test.local` (which will be ignored) and
set the username and password there.