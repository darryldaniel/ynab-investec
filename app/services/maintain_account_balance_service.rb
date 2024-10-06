# frozen_string_literal: true

class MaintainAccountBalanceService
    def initialize(
        investec_client,
        cheque_account,
        savings_account
    )
        @investec_client = investec_client
        @investec_client.authenticate!
        @cheque_account = cheque_account
        @savings_account = savings_account
    end

    def run
        cheque_account_balance = @investec_client.balance @cheque_account.investec_id
        savings_account_balance = @investec_client.balance @savings_account.investec_id
    end
end
