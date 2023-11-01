require "test_helper"

class YnabSyncServiceTest < ActiveSupport::TestCase


    describe "#sync_transactions" do
        let(:primary_account) { accounts(:primary) }
        let(:savings_account) { accounts(:savings) }

        setup do
            freeze_time
        end

        teardown do
            unfreeze_time
        end

        describe "when there is are normal debit transactions" do
            it "should create a transaction in YNAB" do
                transactions = []
                3.times { transactions << InvestecTransactionModel.new(get_investec_api_transaction(primary_account.investec_id)) }
                ynab_transactions = get_ynab_transactions transactions, primary_account.ynab_id
                mock_investec_provider = get_mock_investec_provider transactions
                mock_ynab_provider = get_mock_ynab_provider ynab_transactions
                InvestecProvider.stub :new, mock_investec_provider do
                    YnabProvider.stub :new, mock_ynab_provider do
                        ynab_sync_service = YnabSyncService.new
                        ynab_sync_service.sync_transactions
                    end
                end
                mock_investec_provider.verify
                mock_ynab_provider.verify
            end
        end

        describe "when there is a transfer between accounts" do
            it "should use the other account's id as the payee_id" do
                transfer_transactions = get_transfer_transactions(
                    primary_account.investec_id,
                    savings_account.investec_id).map { |t| InvestecTransactionModel.new(t) }
                ynab_transactions = get_ynab_transactions transfer_transactions,
                                                          primary_account.ynab_id
                ynab_transactions[0].payee_id = savings_account.ynab_id
                ynab_transactions[1].account_id = savings_account.ynab_id
                ynab_transactions[1].payee_id = primary_account.ynab_id
                mock_investec_provider = get_mock_investec_provider(
                    [ transfer_transactions[0] ],
                    [ transfer_transactions[1] ]
                )
                mock_ynab_provider = get_mock_ynab_provider ynab_transactions
                InvestecProvider.stub :new, mock_investec_provider do
                    YnabProvider.stub :new, mock_ynab_provider do
                        ynab_sync_service = YnabSyncService.new
                        ynab_sync_service.sync_transactions
                    end
                end
                mock_investec_provider.verify
                mock_ynab_provider.verify
            end
        end

        describe "when there are 2 transactions on the same day with the same amount" do
            it "should increment the occurrence number of the import_id" do
                api_transaction = InvestecTransactionModel.new(get_investec_api_transaction(primary_account.investec_id))
                repeat_transactions = [
                    api_transaction,
                    api_transaction
                ]
                ynab_transactions = get_ynab_transactions repeat_transactions,
                                                          primary_account.ynab_id
                ynab_transactions[1].import_id = YnabProvider.get_import_id(
                    api_transaction.amount.value * -1,
                    api_transaction.transaction_date,
                    2)
                mock_investec_provider = get_mock_investec_provider repeat_transactions
                mock_ynab_provider = get_mock_ynab_provider ynab_transactions
                ynab_sync_service = YnabSyncService.new
                InvestecProvider.stub :new, mock_investec_provider do
                    YnabProvider.stub :new, mock_ynab_provider do
                        ynab_sync_service.sync_transactions
                    end
                end
                mock_investec_provider.verify
                mock_ynab_provider.verify
            end
        end

        def get_mock_investec_provider(
            primary_account_transactions,
            savings_account_transactions = []
        )
            mock_investec_provider = Minitest::Mock.new
            mock_investec_provider.expect :authenticate!, nil
            mock_investec_provider.expect :get_transactions,
                                          primary_account_transactions,
                                          [
                                              primary_account.investec_id,
                                              7.days.ago,
                                              Date.today
                                          ]
            mock_investec_provider.expect :get_transactions,
                                          savings_account_transactions,
                                          [
                                              savings_account.investec_id,
                                              7.days.ago,
                                              Date.today
                                          ]
            mock_investec_provider
        end

        def get_mock_ynab_provider(ynab_transactions)
            mock_ynab_provider = Minitest::Mock.new
            mock_ynab_provider.expect(
                :create_multiple_transactions,
                nil,
                [
                    ynab_transactions
                ])
            mock_ynab_provider
        end

        def get_ynab_transactions(transactions, account_id)
            transactions.map do |t|
                debit_multiplier = t.is_debit? ? -1 : 1
                amount = t.amount.value * debit_multiplier
                OpenStruct.new({
                                   account_id: account_id,
                                   date: t.transaction_date,
                                   type: t.type,
                                   amount: amount,
                                   payee_id: nil,
                                   payee_name: t.description,
                                   import_id: YnabProvider.get_import_id(
                                       amount,
                                       t.transaction_date),
                                   cleared: "Cleared",
                               })
            end
        end

        def get_transfer_transactions(
            from_account_id,
            to_account_id
        )
            amount = Faker::Number.number(digits: 5)
            date = Faker::Date.between(from: 3.days.ago.to_date, to: Date.today).strftime("%F")
            today = Date.today.strftime("%F")
            [
                {
                    "accountId" => from_account_id,
                    "type" => "DEBIT",
                    "transactionType" => nil,
                    "status" => "POSTED",
                    "description" => "Transfer to Card Internet Value Date 27Oct23",
                    "cardNumber" => "",
                    "postedOrder" => 0,
                    "postingDate" => today,
                    "valueDate" => nil,
                    "actionDate" => date,
                    "transactionDate" => date,
                    "amount" => amount,
                    "runningBalance" => Faker::Number.number(digits: 5)
                },
                {
                    "accountId" => to_account_id,
                    "type" => "CREDIT",
                    "transactionType" => "Deposits",
                    "status" => "POSTED",
                    "description" => "Private Bank Account Deposit",
                    "cardNumber" => "",
                    "postedOrder" => Faker::Number.number(digits: 4),
                    "postingDate" => today,
                    "valueDate" => date,
                    "actionDate" => date,
                    "transactionDate" => date,
                    "amount" => amount,
                    "runningBalance" => Faker::Number.number(digits: 5)
                }
            ]
        end
    end
end
