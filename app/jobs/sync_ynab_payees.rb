# frozen_string_literal: true

class SyncYnabPayees < ApplicationJob
    def perform
        ynab_sync_service = YnabSyncService.new
        ynab_sync_service.sync_payees
    end
end
