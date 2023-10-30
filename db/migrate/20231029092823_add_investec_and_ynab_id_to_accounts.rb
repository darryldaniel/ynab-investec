class AddInvestecAndYnabIdToAccounts < ActiveRecord::Migration[7.1]
    def change
        add_column :accounts, :investec_id, :string
        add_column :accounts, :ynab_id, :string
    end
end
