class YnabSyncService
    def initialize
        @all_import_ids = []
    end

    def sync_transactions
        investec_provider = InvestecProvider.new
        investec_provider.authenticate!
        ynab_accounts = Account
                            .select("ynab_id, investec_id")
                            .where("ynab_id is not null")
        recent_transactions = []
        ynab_accounts.each do |account|
            transactions_for_account = investec_provider.get_transactions(
                account.investec_id,
                7.days.ago,
                Date.today)
            ynab_account_transactions = transactions_for_account.map do |t|
                get_ynab_transaction(t, account.ynab_id)
            end
            recent_transactions.push(*ynab_account_transactions)
        end
        ynab_provider = YnabProvider.new
        transactions_with_transfers = recent_transactions.map do |transaction|
            transfer_match = recent_transactions.find do |match_candidate|
                transaction.amount == (match_candidate.amount * -1) &&
                    transaction.date == match_candidate.date &&
                    transaction.type != match_candidate.type
            end
            unless transfer_match.nil?
                transaction.payee_id = transfer_match.account_id
            end
            transaction
        end
        ynab_provider.create_multiple_transactions transactions_with_transfers
    end

    private

    def get_ynab_transaction(transaction, account_id)
        debit_multiplier = transaction.is_debit? ? -1 : 1
        amount = transaction.amount.value * debit_multiplier
        import_id_occurrence = 1
        import_id = YnabProvider.get_import_id(
            amount,
            transaction.transaction_date)
        while @all_import_ids.include? import_id
            import_id_occurrence += 1
            import_id = YnabProvider.get_import_id(
                amount,
                transaction.transaction_date,
                import_id_occurrence)
        end
        @all_import_ids.push import_id
        OpenStruct.new({
            account_id: account_id,
            date: transaction.transaction_date,
            type: transaction.type,
            amount: amount,
            payee_id: nil,
            payee_name: transaction.description,
            import_id: import_id,
            cleared: "Cleared",
        })
    end
end
