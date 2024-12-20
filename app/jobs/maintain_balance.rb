# frozen_string_literal: true

class MaintainBalance < ApplicationJob
    def perform
        cheque_account = Account.find_by(id: 1)
        savings_account = Account.find_by(id: 2)
        investec_client = InvestecOpenApi::Client.new
        service = MaintainAccountBalanceService.new(
            investec_client,
            cheque_account,
            savings_account
        )
        service.run
    end
end
