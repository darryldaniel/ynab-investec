class Merchant < ApplicationRecord
    has_one :merchant_category
    has_one :country
    has_one :ynab_payee

    def self.create_from_params(params)
        Merchant.find_or_create_by(name: params["name"]) do |merchant|
            merchant.name = params["name"]
            merchant.city = params["city"]
            country_params = params["country"]
            country = Country.find_or_create_by(code: country_params["code"]) do |c|
                c.name = country_params["name"]
                c.alpha3 = country_params["alpha3"]
            end
            merchant.country_id = country.id
            merchant_category_params = params["category"]
            merchant_category = MerchantCategory.find_or_create_by(code: merchant_category_params["code"]) do |mc|
                mc.name = merchant_category_params["name"]
                mc.key = merchant_category_params["key"]
            end
            merchant.merchant_category_id = merchant_category.id
        end
    end
end
