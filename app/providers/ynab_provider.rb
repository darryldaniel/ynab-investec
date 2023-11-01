# frozen_string_literal: true

YNAB_AMOUNT_MULTIPLIER = 1000

class YnabProvider
    def initialize
        @ynab_client = YNAB::API.new ENV.fetch "YNAB_ACCESS_TOKEN"
        @budget_id = ENV.fetch "YNAB_BUDGET_ID"
    end

    def get_accounts
        response = @ynab_client.accounts.get_accounts @budget_id
        response.data.accounts
    end

    def create_transaction(
        amount,
        date,
        payee_name,
        payee_id
    )
        data = {
            transaction: {
                account_id: ENV.fetch("YNAB_INVESTEC_ACCOUNT_ID"),
                amount: YnabProvider.get_ynab_amount(amount),
                date: date,
                payee_name: payee_name,
                payee_id: payee_id
            }
        }
        begin
            @ynab_client.transactions.create_transaction @budget_id, data
        rescue YNAB::ApiError => e
            puts "Error creating transaction: #{e}"
        end
    end

    def create_multiple_transactions(transactions)
        data = {
            transactions: transactions.map do |t|
                {
                    account_id: t.account_id,
                    amount: YnabProvider.get_ynab_amount(t.amount),
                    date: Date.parse(t.date),
                    payee_name: t.payee_name,
                    payee_id: t.payee_id,
                    import_id: t.import_id,
                    cleared: "Cleared"
                }
            end
        }
        begin
            @ynab_client.transactions.create_transaction @budget_id, data
        rescue YNAB::ApiError => e
            puts "Error creating transactions: #{e}"
        end
    end

    def self.get_import_id(
        amount,
        date,
        occurrence = 1
    )
        ynab_amount = YnabProvider.get_ynab_amount amount
        formatted_date = date.is_a?(String) ? date : date.strftime("%F")
        "YNAB:#{ynab_amount}:#{formatted_date}:#{occurrence}"
    end

    def self.get_ynab_amount(amount)
        (amount * YNAB_AMOUNT_MULTIPLIER).round
    end
end
