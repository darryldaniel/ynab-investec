class TransactionsController < ApplicationController
    http_basic_authenticate_with name: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD")
    protect_from_forgery with: :null_session, only: [:create]

    def create
        transaction = Transaction.create_from_params params
        ynab_payee_id = get_ynab_payee_id transaction.merchant
        ynab = YnabProvider.new
        ynab.create_transaction(
            transaction.amount.value * -1, # assume that the transaction is a debit
            transaction.transaction_date.iso8601(3),
            transaction.merchant.name,
            ynab_payee_id)
        render json: "created", status: :created
    end

    private

    def get_ynab_payee_id(merchant)
        unless merchant.ynab_payee_id?
            return nil
        end
        ynab_payee = YnabPayee.find(merchant.ynab_payee_id)
        ynab_payee.ynab_id
    end
end
