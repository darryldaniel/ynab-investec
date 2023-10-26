class InvestecAccountModel
    attr_reader :id
    attr_reader :number
    attr_reader :name
    attr_reader :reference_name
    attr_reader :product_name
    attr_reader :kyc_compliant
    attr_reader :profile_id
    attr_reader :profile_name

    def initialize(params)
        @id = params["accountId"]
        @number = params["accountNumber"]
        @name = params["accountName"]
        @reference_name = params["referenceName"]
        @product_name = params["productName"]
        @kyc_compliant = params["kycCompliant"]
        @profile_id = params["profileId"]
        @profile_name = params["profileName"]
    end
end
