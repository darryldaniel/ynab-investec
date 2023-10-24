class CreateYnabPayees < ActiveRecord::Migration[7.1]
    def change
        create_table :ynab_payees do |t|
            t.string :name
            t.string :ynab_id, limit: 36

            t.timestamps
        end
        add_index :ynab_payees, :ynab_id, unique: true
    end
end
