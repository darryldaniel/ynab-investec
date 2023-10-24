class Transaction < ApplicationRecord
    money_column :amount, currency_column: :currency
    belongs_to :account
    belongs_to :merchant
    belongs_to :card

    def self.create_from_params(params)
        account_number = params["accountNumber"]
        card_investec_id = params["card"]["id"]
        account_and_card = Account.fetch_account_and_card_id(
            account_number: account_number,
            card_investec_id: card_investec_id)
        raise "Could not find account and card for account number #{account_number} and card id #{card_investec_id}" if account_and_card.nil?
        merchant = Merchant.create_from_params params["merchant"]
        Transaction.create(
            account_id: account_and_card.account_id,
            card_id: account_and_card.card_id,
            merchant_id: merchant.id,
            amount: params["centsAmount"].to_i / 100,
            currency: params["currencyCode"].upcase,
            reference: params["reference"],
            transaction_type: params["type"],
            transaction_date: params["dateTime"])
    end
end
