class Account < ApplicationRecord
    has_many :cards

    def self.fetch_account_and_card_id(account_number:, card_investec_id:)
        account_id, card_id = Account
                     .joins(:cards)
                     .where(
                         "accounts.number = ? and cards.investec_id = ?",
                         account_number,
                         card_investec_id)
                     .pluck("accounts.id, cards.id")
                     .first
        return nil if account_id.nil?
        OpenStruct.new(
            account_id: account_id,
            card_id: card_id)
    end
end
