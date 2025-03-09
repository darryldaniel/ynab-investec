class TransactionsController < ApplicationController
    http_basic_authenticate_with name: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD")
    protect_from_forgery with: :null_session, only: [:create]

    def create
        if transaction_in_usd? params
            return render json: "ok", status: :ok
        end
        account_and_card = fetch_account_and_card params
        transaction = Transaction.create_from_params params, account_and_card.account_id, account_and_card.card_id
        ynab_payee_id = get_ynab_payee_id transaction.merchant
        ynab_provider = YnabProvider.new
        ynab_provider.create_transaction(
            account_and_card.account_ynab_id,
            transaction.amount.to_f * -1, # assume that the transaction is a debit
            transaction.transaction_date.iso8601(3),
            transaction.merchant.name,
            ynab_payee_id,
            get_memo_for_transaction
        )
        render json: "created", status: :created
    end

    private

    def fetch_account_and_card(params)
        account_number = params["accountNumber"]
        card_investec_id = params["card"]["id"]
        account_and_card = Account.fetch_account_and_card_id(
            account_number: account_number,
            card_investec_id: card_investec_id)
        raise "Could not find account and card for account number #{account_number} and card id #{card_investec_id}" if account_and_card.nil?
        account_and_card
    end

    def get_ynab_payee_id(merchant)
        unless merchant.ynab_payee_id?
            return nil
        end
        ynab_payee = YnabPayee.find(merchant.ynab_payee_id)
        ynab_payee.ynab_id
    end

    def transaction_in_usd?(params)
        params["currencyCode"].downcase == "usd"
    end

    def get_memo_for_transaction
        "Original Merchant: #{params["merchant"]["name"]}"
    end
end
