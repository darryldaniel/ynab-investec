require "simplecov"
SimpleCov.start
# Previous content of test helper now starts here
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "mocha/minitest"

class Minitest::Spec
    include FactoryBot::Syntax::Methods
end

module ActiveSupport
    class TestCase
        # Run tests in parallel with specified workers
        parallelize(workers: :number_of_processors)

        # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
        fixtures :all

        # Add more helper methods to be used by all tests here...
        def get_card_transaction_params(account_number:, card_investec_id:, currency_code: "ZAR", cents_amount: Faker::Number.number(digits: 5))
            {
                "accountNumber" => account_number,
                "dateTime" => "2023-10-24T08:40:15.338Z",
                "centsAmount" => cents_amount,
                "currencyCode" => currency_code,
                "type" => "card",
                "reference" => Faker::Lorem.words(number: 3).join(" "),
                "card" => {
                    "id" => card_investec_id
                },
                "merchant" => {
                    "category" => {
                        "code" => Faker::Number.number(digits: 4).to_s,
                        "key" => Faker::Company.industry,
                        "name" => Faker::Company.industry
                    },
                    "name" => Faker::Company.name,
                    "city" => Faker::Address.city,
                    "country" => {
                        "code" => Faker::Address.country_code,
                        "alpha3" => Faker::Address.country_code,
                        "name" => Faker::Address.country
                    }
                }
            }
        end

        def get_investec_api_account(account_id = nil)
            {
                "accountId" => account_id || Faker::Number.number(digits: 20).to_s,
                "accountNumber" => Faker::Bank.account_number,
                "accountName" => Faker::Name.name,
                "referenceName" => Faker::Name.name,
                "productName" => Faker::Bank.name,
                "kycCompliant" => true,
                "profileId" => Faker::Number.number(digits: 20).to_s,
                "profileName" => Faker::Name.name
            }
        end

        def get_investec_api_transaction(account_id = nil)
            {
                "accountId" => account_id || Faker::Number.number(digits: 25).to_s,
                "type" => "DEBIT",
                "transactionType" => "CardPurchases",
                "status" => "POSTED",
                "description" => Faker::Lorem.words(number: 4).join(" "),
                "cardNumber" => Faker::Business.credit_card_number,
                "postedOrder" => Faker::Number.number(digits: 4).to_s,
                "postingDate" => Faker::Date.between(from: 1.week.ago.to_date, to: Date.today).strftime("%F"),
                "valueDate" => Faker::Date.between(from: 1.week.ago.to_date, to: Date.today).strftime("%F"),
                "actionDate" => Faker::Date.between(from: 1.week.ago.to_date, to: Date.today).strftime("%F"),
                "transactionDate" => Faker::Date.between(from: 1.week.ago.to_date, to: Date.today).strftime("%F"),
                "amount" => Faker::Commerce.price(range: 100.0..1000.0, as_string: true),
                "runningBalance" => Faker::Commerce.price(range: 100.0..1000.0, as_string: true)
            }
        end
    end
end
