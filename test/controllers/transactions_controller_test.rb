require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
    test "should deny access without credentials" do
        post transaction_url
        assert_equal 401, @response.status
    end

    test "should deny access with invalid credentials" do
        post transaction_url,
             headers: {
                 Authorization: get_auth_credentials(username: "invalid", password: "invalid")
             }
        assert_equal 401, @response.status
    end

    test "should save the transaction and create the transaction in YNAB" do
        account = accounts(:primary)
        card = cards(:debit)
        params = get_transaction_params account_number: account.number, card_investec_id: card.investec_id
        mock = Minitest::Mock.new
        mock.expect :add_transaction,
                    nil,
                    [
                        params["centsAmount"] / 100,
                        params["dateTime"],
                        params["merchant"]["name"],
                        nil
                    ]
        YnabProvider.stub :new, mock do
            post transaction_url,
                 params: params,
                 headers: {
                     Authorization: get_auth_credentials
                 }
        end
        assert_equal 201, @response.status
        saved_transaction = Transaction.find_by(reference: params["reference"])
        assert_not_nil saved_transaction, "transaction was not saved"
        mock.verify
    end

    test "#create should send through payee_id if merchant is linked" do
        account = accounts(:primary)
        card = cards(:debit)
        merchant = merchants(:with_ynab_id)
        ynab_payee = ynab_payees(:woolworths)
        params = get_transaction_params account_number: account.number, card_investec_id: card.investec_id
        params["merchant"]["name"] = merchant.name
        mock = Minitest::Mock.new
        mock.expect :add_transaction,
                    nil,
                    [
                        params["centsAmount"] / 100,
                        params["dateTime"],
                        params["merchant"]["name"],
                        ynab_payee.ynab_id
                    ]
        YnabProvider.stub :new, mock do
            post transaction_url,
                 params: params,
                 headers: {
                     Authorization: get_auth_credentials
                 }
        end
        assert_equal 201, @response.status
        mock.verify
    end

    def get_auth_credentials(username: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD"))
        ActionController::HttpAuthentication::Basic.encode_credentials username, password
    end
end
