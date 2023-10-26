# frozen_string_literal: true

class InvestecProvider
    INVESTEC_API_URL = "https://openapi.investec.com/"

    def initialize(adapter: Faraday.default_adapter, stubs: nil)
        @adapter = adapter
        @stubs = stubs
        @api_key = ENV.fetch("INVESTEC_API_KEY")
        @client_id = ENV.fetch("INVESTEC_CLIENT_ID")
        @client_secret = ENV.fetch("INVESTEC_CLIENT_SECRET")
    end

    def authenticate!
        @token = get_oauth_token
    end

    def get_accounts
        response = connection.get("za/pb/v1/accounts")
        response.body["data"]["accounts"].map { |a| InvestecAccountModel.new a }
    end

    def get_transactions(account_id, from_date, to_date, transaction_type = "")
        from_date = from_date.is_a?(String) ? from_date : from_date.strftime("%F")
        to_date = to_date.is_a?(String) ? to_date : to_date.strftime("%F")
        response = connection.get(
            "za/pb/v1/accounts/#{account_id}/transactions",
            {
                fromDate: from_date,
                toDate: to_date,
                transactionType: transaction_type
            })
        response.body["data"]["transactions"].map { |t| InvestecTransactionModel.new t }
    end

    private

    def get_oauth_token
        auth_token = Base64.strict_encode64("#{@client_id}:#{@client_secret}")
        token_connection = Faraday.new do |conn|
            conn.url_prefix = INVESTEC_API_URL
            conn.request :url_encoded
            conn.response :raise_error
            conn.response :json
            conn.adapter @adapter, @stubs
        end
        response = token_connection.post(
            "/identity/v2/oauth2/token",
            URI.encode_www_form({ grant_type: "client_credentials" }),
            {
                'x-api-key' => @api_key,
                'Authorization' => "Basic #{auth_token}"
            }
        )
        response.body["access_token"]
    end

    def connection
        raise "Authentication required" unless @token
        @connection ||= Faraday.new(url: INVESTEC_API_URL) do |builder|
            builder.headers["Authorization"] = "Bearer #{@token}"
            builder.headers["Accept"] = "application/json"
            builder.request :json
            builder.response :raise_error
            builder.response :json
            builder.adapter @adapter, @stubs
        end
    end
end
