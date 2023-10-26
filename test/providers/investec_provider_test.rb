require "test_helper"
require "json"

class InvestecProviderTest < ActiveSupport::TestCase

    describe "#authenticate!" do
        it "should authenticate with Investec and return a token" do
            auth_stubs = get_stubs
            investec = InvestecProvider.new adapter: :test, stubs: auth_stubs
            investec.authenticate!
            auth_stubs.verify_stubbed_calls
        end
    end

    describe "#get_accounts" do
        it 'should get all available accounts from investec' do
            accounts_response = get_accounts_response
            stubs = get_stubs do |stub|
                stub.get("/za/pb/v1/accounts") { [200, {}, accounts_response.as_json] }
            end
            investec = InvestecProvider.new adapter: :test, stubs: stubs
            investec.authenticate!
            accounts = investec.get_accounts
            stubs.verify_stubbed_calls
            first_account = accounts[0]
            result = accounts_response["data"]["accounts"][0]
            expect(first_account.id).must_equal result["accountId"]
            expect(first_account.number).must_equal result["accountNumber"]
            expect(first_account.name).must_equal result["accountName"]
            expect(first_account.reference_name).must_equal result["referenceName"]
            expect(first_account.product_name).must_equal result["productName"]
            expect(first_account.kyc_compliant).must_equal result["kycCompliant"]
            expect(first_account.profile_id).must_equal result["profileId"]
            expect(first_account.profile_name).must_equal result["profileName"]
        end
    end

    describe "#get_transactions" do
        it 'should get all of the transactions for the requested dates' do
            transactions_response = get_transactions_response
            account_id = transactions_response["data"]["transactions"][0]["accountId"]
            stubs = get_stubs do |stub|
                stub.get(
                    "za/pb/v1/accounts/#{account_id}/transactions"
                ) { [200, {}, transactions_response.as_json] }
            end
            investec = InvestecProvider.new adapter: :test, stubs: stubs
            investec.authenticate!
            transactions = investec.get_transactions(
                account_id,
                7.days.ago,
                Date.today)
            stubs.verify_stubbed_calls
            first_transaction = transactions[0]
            result = transactions_response["data"]["transactions"][0]
            expect(first_transaction.account_id).must_equal result["accountId"]
            expect(first_transaction.type).must_equal result["type"]
            expect(first_transaction.transaction_type).must_equal result["transactionType"]
            expect(first_transaction.status).must_equal result["status"]
            expect(first_transaction.description).must_equal result["description"]
            expect(first_transaction.card_number).must_equal result["cardNumber"]
            expect(first_transaction.posted_order).must_equal result["postedOrder"]
            expect(first_transaction.posting_date).must_equal result["postingDate"]
            expect(first_transaction.value_date).must_equal result["valueDate"]
            expect(first_transaction.action_date).must_equal result["actionDate"]
            expect(first_transaction.transaction_date).must_equal result["transactionDate"]
            expect(first_transaction.amount).must_equal result["amount"]
            expect(first_transaction.running_balance).must_equal result["runningBalance"]
        end
    end

    def get_stubs
        Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post(
                "/identity/v2/oauth2/token",
                URI.encode_www_form({ grant_type: "client_credentials" }),
            ) { [200, {}, { "access_token" => "test_token" }.to_json] }
            yield stub if block_given?
        end
    end

    def get_accounts_response
        {
            "data" => {
                "accounts" => [
                    {
                        "accountId" => Faker::Number.number(digits: 20).to_s,
                        "accountNumber" => Faker::Bank.account_number,
                        "accountName" => Faker::Name.name,
                        "referenceName" => Faker::Name.name,
                        "productName" => "Private Bank Account",
                        "kycCompliant" => true,
                        "profileId" => Faker::Number.number(digits: 20).to_s,
                        "profileName" => Faker::Name.name
                    }
                ]
            }
        }
    end

    def get_transactions_response
        {
            "data" => {
                "transactions" => [
                    {
                        "accountId" => Faker::Number.number(digits: 25).to_s,
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
                ]
            }
        }
    end

end
