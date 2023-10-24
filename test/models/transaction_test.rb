require "test_helper"

class TransactionTest < ActiveSupport::TestCase
    test "create_from_params should create a new transaction" do
        account = accounts(:primary)
        card = cards(:debit)
        params = get_transaction_params account_number: account.number, card_investec_id: card.investec_id
        created_transaction = Transaction.create_from_params params
        transaction = Transaction.find_by(id: created_transaction.id)
        assert_equal params["reference"], transaction.reference
        assert_equal params["centsAmount"] / 100, transaction.amount.value
        assert_equal "South African Rand", transaction.amount.currency.name
        assert_equal params["dateTime"], transaction.transaction_date.iso8601(3)
    end
end