# frozen_string_literal: true

class SyncYnab < ApplicationJob
    def perform
        Cronitor.api_key = ENV.fetch "CRONITOR_API_KEY"
        monitor = Cronitor::Monitor.new "sync-ynab"
        monitor.ping state: "run"
        result = YnabSyncService.new.sync_transactions
        monitor.ping state: "complete",
                     message: URI.encode_uri_component(result)
    end
end
