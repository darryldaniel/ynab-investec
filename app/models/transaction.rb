class Transaction < ApplicationRecord
    monetize :amount_cents
    belongs_to :account
    belongs_to :merchant
    belongs_to :card

    def self.create_from_params(params, account_id, card_id)
        merchant = Merchant.create_from_params params["merchant"]
        Transaction.create(
            account_id: account_id,
            card_id: card_id,
            merchant_id: merchant.id,
            amount_cents: params["centsAmount"],
            currency: params["currencyCode"].upcase,
            reference: params["reference"],
            transaction_type: params["type"],
            transaction_date: params["dateTime"])
    end
end
