require "test_helper"

class MerchantTest < ActiveSupport::TestCase
    test "create_from_params should create a merchant" do
        params = get_merchant_params
        created_merchant = Merchant.create_from_params params["merchant"]
        merchant = Merchant.find_by(id: created_merchant.id)
        assert_equal "The Coders Bakery", merchant.name
    end
end

def get_merchant_params
    {
        "merchant" => {
            "category" => {
                "code" => "5462",
                "key" => "bakeries",
                "name" => "Bakeries"
            },
            "name" => "The Coders Bakery",
            "city" => "Cape Town",
            "country" => {
                "code" => "ZA",
                "alpha3" => "ZAF",
                "name" => "South Africa"
            }
        }
    }
end
