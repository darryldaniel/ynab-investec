class RenameAmountToAmountCents < ActiveRecord::Migration[7.1]
    def change
        rename_column :transactions, :amount, :amount_cents
    end
end
