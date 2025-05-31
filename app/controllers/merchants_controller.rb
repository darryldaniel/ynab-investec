# frozen_string_literal: true

class MerchantsController < ApplicationController
    def show
        @merchant = Merchant.find_by(id: params[:id])
    end

    def index
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        @merchants = Merchant.where("ynab_payee_id is null and exclude_from_ynab_mapping = false").sort_by(&:name)
        @ynab_payees = YnabPayee.all.sort_by(&:name)
    end

    def exclude_from_mapping
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        merchant = Merchant.find_by(id: params[:merchant_id])
        merchant.update(exclude_from_ynab_mapping: true)
        redirect_to merchant_path(merchant)
    end

    def update_ynab_mapping
        unless user_signed_in?
            redirect_to new_session_path
            return
        end
        merchant = Merchant.find_by(id: params[:merchant_id])
        merchant.update(ynab_payee_id: params[:payee])
        redirect_to merchant_path(merchant)
    end
end
