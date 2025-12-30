class TasksController < ApplicationController
    before_action :create_sync_service, only: [:sync_ynab_payees, :sync_ynab_transactions]

    def index
        redirect_to new_session_path unless user_signed_in?
    end

    def sync_ynab_payees
        redirect_to new_session_path unless user_signed_in?

        @sync_service.sync_payees
        head :ok
    end

    def sync_ynab_transactions
        redirect_to new_session_path unless user_signed_in?

        @sync_service.sync_transactions
        head :ok
    end

    def maintain_balances
        redirect_to new_session_path unless user_signed_in?

        cheque_account = Account.find_by(id: 1)
        savings_account = Account.find_by(id: 2)
        investec_client = InvestecOpenApi::Client.new
        service = MaintainAccountBalanceService.new(
            investec_client,
            cheque_account,
            savings_account
        )
        service.run
        head :ok
    end

    private

    def create_sync_service
        @sync_service = YnabSyncService.new
    end
end
