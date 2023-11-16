require "logger"

class YnabSyncService
    def sync_transactions
        investec_provider = InvestecOpenApi::Client.new
        investec_provider.authenticate!
        ynab_accounts = Account
                            .select(:ynab_id, :investec_id, :name)
                            .where("ynab_id is not null")
        recent_transactions = []
        all_import_ids = []
        ynab_accounts.each do |account|
            transactions_for_account = investec_provider.transactions(
                account.investec_id,
                {
                    from_date: 7.days.ago.strftime("%F"),
                    to_date: Date.today.strftime("%F"),
                })
            ynab_account_transactions = transactions_for_account.map { |t|
                YnabTransactionModel.from_transaction(t, account.ynab_id, all_import_ids)
            }
            recent_transactions.push(*ynab_account_transactions)
        end
        ynab_provider = YnabProvider.new
        transactions_with_transfers = YnabTransactionModel.match_transfer_transactions recent_transactions
        response = ynab_provider.create_multiple_transactions transactions_with_transfers.map(&:to_save_transaction)
        get_result_message response.data
    end

    def sync_payees
        ynab_provider = YnabProvider.new
        payees = ynab_provider.get_payees
        YnabPayee.insert_all payees.map { |p| { name: p.name, ynab_id: p.id } }
        log "Payees synced!"
    end

    private

    def logger
        @logger ||= Logger.new $stdout
    end

    def log(message)
        logger.info message
    end

    def get_result_message(ynab_data)
        messages = []
        messages.push("Duplicate imports:")
        messages.push(*ynab_data.duplicate_import_ids)
        messages.push("Transactions created:")
        messages.push(*ynab_data.transactions.map { |transaction| "#{transaction.date} #{transaction.payee_name} R#{transaction.amount.to_f / 100}" })
        messages.join("\n")
    end
end
