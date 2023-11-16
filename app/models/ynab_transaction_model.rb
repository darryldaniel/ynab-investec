# frozen_string_literal: true

class YnabTransactionModel
    attr_reader :account_id,
                :date,
                :type,
                :amount,
                :import_id,
                :cleared,
                :payee_name
    attr_writer :payee_id

    def initialize(
        account_id:,
        date:,
        type:,
        amount:,
        import_id:,
        cleared: "Cleared",
        payee_id: nil,
        payee_name:
    )
        @account_id = account_id
        @date = date
        @type = type
        @amount = amount
        @import_id = import_id
        @cleared = cleared
        @payee_id = payee_id
        @payee_name = payee_name
    end

    def to_save_transaction
        OpenStruct.new({
            account_id: @account_id,
            date: @date,
            type: @type,
            amount: @amount,
            payee_id: @payee_id,
            payee_name: @payee_name,
            import_id: @import_id,
            cleared: @cleared,
        })
    end

    def is_transaction_a_transfer_match?(match_candidate)
        @amount == (match_candidate.amount * -1) &&
            @date == match_candidate.date &&
            @type != match_candidate.type
    end

    def self.from_transaction(
        transaction,
        account_id,
        current_import_ids = [])
        transaction_date = transaction.date.strftime("%F")
        amount = transaction.amount.to_f
        import_id_occurrence = 1
        import_id = YnabProvider.get_import_id(
            amount,
            transaction_date)
        while current_import_ids.include? import_id
            import_id_occurrence += 1
            import_id = YnabProvider.get_import_id(
                amount,
                transaction_date,
                import_id_occurrence)
        end
        current_import_ids.push import_id
        YnabTransactionModel.new(
            account_id: account_id,
            date: transaction_date,
            type: transaction.type,
            amount: amount,
            payee_name: transaction.description,
            import_id: import_id)
    end

    def self.match_transfer_transactions(transactions)
        transactions.map do |transaction|
            transfer_match = transactions.find {
                |match_candidate| transaction.is_transaction_a_transfer_match? match_candidate
            }
            unless transfer_match.nil?
                transaction.payee_id = transfer_match.account_id
            end
            transaction
        end
    end
end
