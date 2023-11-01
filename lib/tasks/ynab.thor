class Ynab < Thor
    desc "sync", "Syncs transactions from the last 7 days with YNAB"

    def sync
        ynab_sync_service = YnabSyncService.new
        ynab_sync_service.sync_transactions
    end
end
