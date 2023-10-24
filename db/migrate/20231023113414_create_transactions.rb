class CreateTransactions < ActiveRecord::Migration[7.1]
    def change
        create_table :transactions do |t|
            t.belongs_to :account, null: false, foreign_key: false
            t.decimal :amount, precision: 21, scale: 3, null: false
            t.string :currency, limit: 3, null: false
            t.datetime :transaction_date, null: false
            t.belongs_to :merchant, null: true, foreign_key: false
            t.string :reference
            t.string :transaction_type
            t.belongs_to :card, null: true, foreign_key: false
            t.string :ynab_import_id
            t.boolean :is_cleared, default: false

            t.timestamps
        end
    end
end
