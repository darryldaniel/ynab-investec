# CLAUDE.md

## Project Overview

YNAB Investec is a **Ruby on Rails 7.2** application that connects [Investec](https://www.investec.com/) bank accounts to [YNAB (You Need A Budget)](https://www.ynab.com/) for automated transaction syncing, merchant mapping, and balance maintenance between cheque and savings accounts.

**Ruby version:** 3.3.3
**Database:** MySQL 8.3
**Deployment:** Docker via Kamal to `ynab-investec.darryldaniel.dev`

## Quick Reference

```bash
# Setup
bin/setup                          # Install deps, create DB, run migrations

# Run the app
bin/rails server                   # Start Puma on port 3000
bin/rails tailwindcss:watch        # Watch and compile Tailwind CSS

# Tests
bin/rails test                     # Run all tests
bin/rails test test/models/        # Run model tests only
bin/rails test test/services/      # Run service tests only

# Database
bin/rails db:migrate               # Run pending migrations
bin/rails db:schema:load           # Load schema from db/schema.rb

# Thor tasks (manual triggers)
bundle exec thor ynab:sync         # Sync Investec transactions to YNAB
bundle exec thor ynab:sync_payees  # Sync YNAB payees to local DB
bundle exec thor balance:maintain_balance  # Run balance maintenance

# Deployment
kamal deploy                       # Deploy via Kamal
```

## Architecture

### Directory Structure

```
app/
├── controllers/       # Rails controllers (webhook, auth, merchant mapping, tasks)
├── jobs/              # Solid Queue background jobs (SyncYnab, MaintainBalance, SyncYnabPayees)
├── models/            # ActiveRecord models + API data models (Investec*, Ynab*)
├── providers/         # API client wrappers (InvestecProvider, YnabProvider)
├── services/          # Business logic (YnabSyncService, MaintainAccountBalanceService)
├── views/             # ERB templates with Tailwind CSS
├── javascript/        # Stimulus controllers (nav, merchant mapping)
└── assets/            # Stylesheets (Tailwind CSS)
config/
├── routes.rb          # Route definitions
├── database.yml       # MySQL config (banking_development / banking_test)
├── deploy.yml         # Kamal deployment config
├── recurring.yml      # Solid Queue scheduled jobs
├── queue.yml          # Solid Queue worker config
└── schedule.rb        # Whenever cron config (legacy)
db/
├── schema.rb          # Current database schema
└── migrate/           # Database migrations
lib/tasks/             # Thor tasks (ynab.thor, balance-maintainer.thor)
test/
├── models/            # Model unit tests (8 files)
├── controllers/       # Controller integration tests
├── services/          # Service tests with API mocking
├── providers/         # Provider tests
├── tasks/             # Thor task tests
└── fixtures/          # YAML test fixtures
```

### Design Patterns

- **Service Objects:** `YnabSyncService`, `MaintainAccountBalanceService` encapsulate business logic
- **Provider Pattern:** `InvestecProvider`, `YnabProvider` abstract external API interactions
- **API Data Models:** `InvestecTransactionModel`, `YnabTransactionModel` transform between API formats
- **Background Jobs:** Solid Queue (in-database) for async/scheduled job processing

### Key Data Flows

**Webhook transaction (real-time):**
1. Investec sends POST to `/transaction` (HTTP Basic Auth)
2. `TransactionsController#create` filters USD transactions, creates local `Transaction`
3. Looks up merchant's YNAB payee mapping if available
4. Calls `YnabProvider` to create the transaction in YNAB

**Scheduled sync (hourly):**
1. `SyncYnab` job triggers `YnabSyncService#sync_transactions`
2. Fetches last 7 days of Investec transactions per account
3. `YnabTransactionModel` converts and detects transfers between accounts
4. Batch-creates transactions in YNAB

**Balance maintenance (daily at 1am):**
1. `MaintainBalance` job triggers `MaintainAccountBalanceService#run`
2. If cheque balance < R2,000 and savings >= R2,000: transfers from savings to cheque
3. If cheque balance > R5,000: transfers excess (rounded to R1,000) to savings

## Database

Core tables: `accounts`, `cards`, `transactions`, `merchants`, `merchant_categories`, `countries`, `users`, `ynab_payees`. Solid Queue adds its own `solid_queue_*` tables.

**Money handling:** Amounts stored as `decimal(21,3)` in cents using the `money-rails` gem. Default currency is ZAR with `ROUND_HALF_UP` rounding.

**YNAB amount format:** Millicents (multiply by 1000).

## Testing

**Framework:** Minitest with spec-style syntax (`minitest-spec-rails`)
**Coverage:** SimpleCov (runs automatically)
**Fixtures:** YAML-based in `test/fixtures/`
**Mocking:** `mocha` gem + `Minitest::Mock` for API clients

### Conventions

- Use `describe` blocks (Minitest::Spec style)
- Mock all external API calls — never hit real Investec/YNAB APIs in tests
- Use fixtures for database records, `Faker` for dynamic test data
- Helper methods in `test_helper.rb`: `get_card_transaction_params`, `get_investec_api_account`, `get_investec_api_transaction`
- Time-dependent tests use `freeze_time` / `unfreeze_time`
- Tests run in parallel with `parallelize(workers: :number_of_processors)`

### Running Tests

```bash
bin/rails test                           # All tests
bin/rails test test/models/              # Model tests
bin/rails test test/controllers/         # Controller tests
bin/rails test test/services/            # Service tests
bin/rails test test/services/ynab_sync_service_test.rb  # Single file
```

## Environment Variables

Base development values live in `.env.development`. Sensitive credentials go in `.env.development.local` (gitignored).

| Variable | Purpose |
|---|---|
| `INVESTEC_API_KEY` | Investec Open API key |
| `INVESTEC_CLIENT_ID` | Investec OAuth client ID |
| `INVESTEC_CLIENT_SECRET` | Investec OAuth client secret |
| `YNAB_ACCESS_TOKEN` | YNAB personal access token |
| `YNAB_BUDGET_ID` | YNAB budget UUID |
| `APP_USERNAME` | HTTP Basic Auth username (webhook) |
| `APP_PASSWORD` | HTTP Basic Auth password (webhook) |
| `CRONITOR_API_KEY` | Cronitor monitoring API key |
| `MYSQL_USERNAME` | Database username (default: `banking`) |
| `MYSQL_PASSWORD` | Database password (default: `banking`) |

## External API Integrations

### Investec Open API
- OAuth 2.0 client credentials flow
- Base URL: `https://openapi.investec.com/`
- Used for: account listing, transaction retrieval, balance checks, inter-account transfers
- Client: `InvestecOpenApi::Client` (from `investec_open_api` gem) and custom `InvestecProvider` (Faraday-based)

### YNAB API
- REST API via `ynab` Ruby gem
- Used for: creating transactions (single + batch), fetching payees and accounts
- Amounts are in millicents (multiply cents by 1000)

### Cronitor
- Monitors the `sync-ynab` scheduled job
- Pings with `run` state at start, `complete` state with result

## Key Conventions

- **No linter/formatter configured** — follow existing code style (4-space indentation in Ruby files)
- **Commit messages** use emoji prefixes in existing history
- **Frontend:** Tailwind CSS for styling, Stimulus (Hotwire) for JavaScript behavior, Importmap for JS modules
- **Job queue:** Solid Queue (in-database, not Redis-backed) — configured in `config/queue.yml` and `config/recurring.yml`
- **Currency:** All monetary values in ZAR unless specified. Use `money-rails` helpers for Money objects
- **Authentication:** Session-based for web UI, HTTP Basic Auth for the webhook endpoint
- **No CI pipeline configured** — run `bin/rails test` locally before pushing

## Common Gotchas

- The `investec_open_api` gem is pinned to a specific Git ref (`0196a5`), not a released version
- USD transactions are silently skipped in the webhook handler (`TransactionsController#create`)
- YNAB import IDs must be unique — the sync service tracks all IDs to avoid duplicates
- Transfer detection logic in `YnabTransactionModel.match_transfer_transactions` matches debits in one account with credits in another of the same amount and date
- The balance maintenance service subtracts R50,000 (in cents) from the available cheque balance as a baseline offset before applying thresholds
