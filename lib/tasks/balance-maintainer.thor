# frozen_string_literal: true

class BalanceMaintainer < Thor
    desc "maintain_balance", "Ensures that there are the right amount of funds in cheque and savings"
    def maintain_balance
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
