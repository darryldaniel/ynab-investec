class CreateMerchants < ActiveRecord::Migration[7.1]
    def change
        create_table :merchants do |t|
            t.string :name
            t.string :city
            t.belongs_to :country, null: false, foreign_key: false
            t.belongs_to :merchant_category, null: false, foreign_key: false
            t.belongs_to :ynab_payee, null: true, foreign_key: false

            t.timestamps
        end
        add_index :merchants, :name, unique: true
    end
end
