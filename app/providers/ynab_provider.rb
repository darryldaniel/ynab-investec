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

    def add_transaction(
        amount,
        date,
        payee_name,
        payee_id
    )
        p "payee id: #{payee_id}"
        data = {
            transaction: {
                account_id: ENV.fetch("YNAB_INVESTEC_ACCOUNT_ID"),
                amount: get_ynab_amount(amount),
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

    def get_ynab_amount(amount)
        (amount * YNAB_AMOUNT_MULTIPLIER).round * -1
    end
end
