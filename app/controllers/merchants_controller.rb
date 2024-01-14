# frozen_string_literal: true

class MerchantsController < ApplicationController

    def map_ynab
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        @merchants = Merchant.where("ynab_payee_id is null")
        @ynab_payees = YnabPayee.all.sort_by(&:name)
    end

    def update_ynab_mapping
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        merchant = Merchant.find(params[:merchant_id])
        merchant.update(ynab_payee_id: params[:payee])
        redirect_to map_ynab_merchants_path
    end
end
