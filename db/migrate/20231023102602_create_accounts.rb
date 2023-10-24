class CreateAccounts < ActiveRecord::Migration[7.1]
    def change
        create_table :accounts do |t|
            t.string :name, null: false
            t.string :number, null: false

            t.timestamps
        end
        add_index :accounts, :number, unique: true
    end
end
