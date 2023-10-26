class InvestecTransactionModel
    # add attr_accessors for all the fields you want to use
    attr_reader :account_id
    attr_reader :type
    attr_reader :transaction_type
    attr_reader :status
    attr_reader :description
    attr_reader :card_number
    attr_reader :posted_order
    attr_reader :posting_date # date the transaction was cleared
    attr_reader :value_date
    attr_reader :action_date
    attr_reader :transaction_date # date the transaction was made
    attr_reader :amount
    attr_reader :running_balance

    def initialize(params)
        @account_id = params["accountId"]
        @type = params["type"]
        @transaction_type = params["transactionType"]
        @status = params["status"]
        @description = params["description"]
        @card_number = params["cardNumber"]
        @posted_order = params["postedOrder"]
        @posting_date = params["postingDate"]
        @value_date = params["valueDate"]
        @action_date = params["actionDate"]
        @transaction_date = params["transactionDate"]
        @amount = params["amount"]
        @running_balance = params["runningBalance"]
    end
end
