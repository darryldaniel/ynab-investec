class AddExcludeFromYnabMappingToMerchants < ActiveRecord::Migration[7.1]
    def change
        add_column :merchants, :exclude_from_ynab_mapping, :boolean, default: false
    end
end
