class CreateMerchantCategories < ActiveRecord::Migration[7.1]
    def change
        create_table :merchant_categories do |t|
            t.integer :code, null: false
            t.string :key, null: false
            t.string :name, null: false

            t.timestamps
        end
        add_index :merchant_categories, :code, unique: true
    end
end
