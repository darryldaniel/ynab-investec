# frozen_string_literal: true

InvestecOpenApi.configuration do |config|
    config.api_key       = ENV['INVESTEC_API_KEY']
    config.client_id     = ENV['INVESTEC_CLIENT_ID']
    config.client_secret = ENV['INVESTEC_CLIENT_SECRET']
end
