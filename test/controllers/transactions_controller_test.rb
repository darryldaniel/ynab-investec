require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
    describe "POST #create" do
        describe "when no credentials provided" do
            it "should deny access" do
                post transaction_url
                assert_equal 401, @response.status
            end
        end

        describe "when credentials are invalid" do
            it "should deny access" do
                post transaction_url,
                     headers: {
                         Authorization: get_auth_credentials(username: "invalid", password: "invalid")
                     }
                assert_equal 401, @response.status
            end
        end

        it "should save the transaction and create the transaction in YNAB" do
            account = accounts(:primary)
            card = cards(:debit)

            params = get_card_transaction_params account_number: account.number,
                                                 card_investec_id: card.investec_id,
                                                 cents_amount: 11999
            ynab_provider_mock = Minitest::Mock.new
            ynab_provider_mock.expect :create_transaction,
                                      nil,
                                      [
                                          account.ynab_id,
                                          -119.99,
                                          params["dateTime"],
                                          params["merchant"]["name"],
                                          nil,
                                          "Original Merchant: #{params["merchant"]["name"]}"
                                      ]
            YnabProvider.stub :new, ynab_provider_mock do
                post transaction_url,
                     params: params,
                     headers: {
                         Authorization: get_auth_credentials
                     }
            end
            assert_equal 201, @response.status
            ynab_provider_mock.verify
            saved_transaction = Transaction.find_by(reference: params["reference"])
            assert_not_nil saved_transaction, "transaction was not saved"
        end

        describe "when a merchant is linked to a YNAB payee" do
            it "should send through the linked payee_id" do
                account = accounts(:primary)
                card = cards(:debit)
                merchant = merchants(:with_ynab_id)
                ynab_payee = ynab_payees(:woolworths)
                params = get_card_transaction_params account_number: account.number, card_investec_id: card.investec_id
                params["merchant"]["name"] = merchant.name
                mock = Minitest::Mock.new
                mock.expect :create_transaction,
                            nil,
                            [
                                account.ynab_id,
                                params["centsAmount"].to_f / 100 * -1,
                                params["dateTime"],
                                params["merchant"]["name"],
                                ynab_payee.ynab_id,
                                "Original Merchant: #{params["merchant"]["name"]}"
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
        end

        describe "when the transaction is in usd" do
            it 'should not save the transaction or send it through to ynab' do
                account = accounts(:primary)
                card = cards(:debit)
                params = get_card_transaction_params account_number: account.number, card_investec_id: card.investec_id
                params["currencyCode"] = "USD"
                ynab_provider_mock = Minitest::Mock.new
                YnabProvider.stub :new, ynab_provider_mock do
                    post transaction_url,
                         params: params,
                         headers: {
                             Authorization: get_auth_credentials
                         }
                end
                assert_equal 200, @response.status
                saved_transaction = Transaction.find_by(reference: params["reference"])
                assert_nil saved_transaction, "transaction was not saved"

            end
        end
    end

    def get_auth_credentials(username: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD"))
        ActionController::HttpAuthentication::Basic.encode_credentials username, password
    end
end
