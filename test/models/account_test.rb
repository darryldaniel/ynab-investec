require "test_helper"

class AccountTest < ActiveSupport::TestCase
    test "#fetch_account_and_card_id should return account_id and card_id" do
        result = Account.fetch_account_and_card_id(
            account_number: "1234567890",
            card_investec_id: "12345")
        assert_equal 1,  result.account_id
        assert_equal 1, result.card_id
    end

    test "#fetch_account_and_card_id should return nil if account_number is not found" do
        result = Account.fetch_account_and_card_id(
            account_number: "-1",
            card_investec_id: "-1")
        assert_nil result
    end
end
