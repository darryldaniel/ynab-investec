ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def get_transaction_params(account_number:, card_investec_id:, currency_code: "ZAR")
        {
            "accountNumber" => account_number,
            "dateTime" => "2023-10-24T08:40:15.338Z",
            "centsAmount" => Faker::Number.number(digits: 5),
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
  end
end
