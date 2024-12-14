# frozen_string_literal: true

class MerchantsController < ApplicationController

    def map_ynab
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        @merchants = Merchant.where("ynab_payee_id is null and exclude_from_ynab_mapping = false").sort_by(&:name)
        @ynab_payees = YnabPayee.all.sort_by(&:name)
    end

    def exclude_from_ynab_mapping
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        merchant = Merchant.find(params[:merchant_id])
        merchant.update(exclude_from_ynab_mapping: true)
        redirect_to map_ynab_merchants_path
    end

    def update_ynab_mapping
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        merchant = Merchant.find(params[:merchant_id])
        if params[:exclude].to_i.positive?
            merchant.update(exclude_from_ynab_mapping: true)
        else
            merchant.update(ynab_payee_id: params[:payee])
        end
        redirect_to map_ynab_merchants_path
    end
end
