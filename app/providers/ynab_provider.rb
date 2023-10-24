# frozen_string_literal: true

class YnabProvider
    def initialize
        @ynab_client = YNAB::API.new ENV.fetch "YNAB_ACCESS_TOKEN"
        @budget_id = ENV.fetch "YNAB_BUDGET_ID"
    end

    def get_accounts
        response = @ynab_client.accounts.get_accounts @budget_id
        response.data.accounts
    end
end
