class CreateCards < ActiveRecord::Migration[7.1]
    def change
        create_table :cards do |t|
            t.string :name, null: false
            t.string :investec_id, null: false
            t.string :number, null: false
            t.belongs_to :account, null: false, foreign_key: false

            t.timestamps
        end
        add_index :cards, :number, unique: true
        add_index :cards, :investec_id, unique: true
    end
end
