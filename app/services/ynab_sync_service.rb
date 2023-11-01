require "logger"

class YnabSyncService
    def sync_transactions
        log "Starting sync..."
        investec_provider = InvestecProvider.new
        investec_provider.authenticate!
        ynab_accounts = Account
                            .select(:ynab_id, :investec_id, :name)
                            .where("ynab_id is not null")
        recent_transactions = []
        all_import_ids = []
        ynab_accounts.each do |account|
            log "Getting transactions for #{account.name}"
            transactions_for_account = investec_provider.get_transactions(
                account.investec_id,
                7.days.ago,
                Date.today)
            ynab_account_transactions = transactions_for_account.map { |t|
                YnabTransactionModel.from_transaction(t, account.ynab_id, all_import_ids)
            }
            recent_transactions.push(*ynab_account_transactions)
        end
        ynab_provider = YnabProvider.new
        transactions_with_transfers = YnabTransactionModel.match_transfer_transactions recent_transactions
        response = ynab_provider.create_multiple_transactions transactions_with_transfers.map(&:to_save_transaction)
        log_result response
    end

    private

    def logger
        @logger ||= Logger.new $stdout
    end

    def log(message)
        logger.info message
    end

    def log_result(response)
        if !response.data.duplicate_import_ids.empty?
            log "Duplicate Imports:"
            log "-----"
            response.data.duplicate_import_ids.each { |import_id| log import_id }
        else
            log "No duplicate imports"
        end
        if !response.data.transaction_ids.empty?
            log "Transactions Created:"
            log "-----"
            response.data.transactions.each { |transaction| log transaction }
        else
            log "No transactions created"
        end
    end
end
