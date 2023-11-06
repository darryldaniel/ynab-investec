# frozen_string_literal: true

class MerchantsController < ApplicationController
    http_basic_authenticate_with name: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD"), only: [:map_ynab, :update_ynab_mapping]

    def map_ynab
        @merchants = Merchant.where("ynab_payee_id is null")
        @ynab_payees = YnabPayee.all.sort_by(&:name)
    end

    def update_ynab_mapping
        merchant = Merchant.find(params[:merchant_id])
        merchant.update(ynab_payee_id: params[:payee])
        redirect_to map_ynab_merchants_path
    end
end
