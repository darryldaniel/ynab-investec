require "cronitor"

class Ynab < Thor
    desc "sync", "Syncs transactions from the last 7 days with YNAB"
    def sync
        Cronitor.api_key = ENV.fetch "CRONITOR_API_KEY"
        monitor = Cronitor::Monitor.new "sync-ynab"
        monitor.ping state: "run"
        result = YnabSyncService.new.sync_transactions
        monitor.ping state: "complete",
                     message: URI.encode_uri_component(result)
    end

    desc "sync_payees", "Syncs payees from YNAB"
    def sync_payees
        ynab_sync_service = YnabSyncService.new
        ynab_sync_service.sync_payees
    end
end
