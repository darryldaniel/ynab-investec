require "test_helper"

class TransactionTest < ActiveSupport::TestCase
    test "create_from_params should create a new transaction" do
        params = get_transaction_params
        created_transaction = Transaction.create_from_params params
        transaction = Transaction.find_by(id: created_transaction.id)
        assert_equal "simulation", transaction.reference
        assert_equal 100.0, transaction.amount.value
        assert_equal "South African Rand", transaction.amount.currency.name
        assert_equal "2023-10-23T03:22:47.329Z", transaction.transaction_date.iso8601(3)
    end
end

def get_transaction_params
    {
        "accountNumber" => "1234567890",
        "dateTime" => "2023-10-23T03:22:47.329Z",
        "centsAmount" => 10000,
        "currencyCode" => "zar",
        "type" => "card",
        "reference" => "simulation",
        "card" => {
            "id" => "12345"
        },
        "merchant" => {
            "category" => {
                "code" => "5462",
                "key" => "bakeries",
                "name" => "Bakeries"
            },
            "name" => "The Coders Bakery",
            "city" => "Cape Town",
            "country" => {
                "code" => "ZA",
                "alpha3" => "ZAF",
                "name" => "South Africa"
            }
        }
    }
end
