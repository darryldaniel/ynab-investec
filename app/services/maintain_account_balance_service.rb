# frozen_string_literal: true

class MaintainAccountBalanceService
    def initialize(
        investec_client,
        cheque_account,
        savings_account
    )
        @investec_client = investec_client
        @investec_client.authenticate!
        @cheque_account = cheque_account
        @savings_account = savings_account
    end

    def run
        cheque_account_balance = @investec_client.balance @cheque_account.investec_id
        savings_account_balance = @investec_client.balance @savings_account.investec_id
        available_cheque_balance = cheque_account_balance.available_balance.cents / 100 - 50_000
        current_savings_balance = savings_account_balance.current_balance.cents / 100
        puts "Cheque Available: #{available_cheque_balance}"
        puts "Current Savings: #{current_savings_balance}"
        check_and_transfer_to_cheque_if_applicable available_cheque_balance,
                                                   current_savings_balance
        check_and_transfer_to_savings_if_applicable available_cheque_balance
    end

    def check_and_transfer_to_cheque_if_applicable(
        available_cheque_balance,
        current_savings_balance
    )
        if available_cheque_balance < 2_000
            return if current_savings_balance < 2_000

            puts "Transferring R2000 to Cheque"
            @investec_client.transfer_multiple(
                @savings_account.investec_id,
                [
                    InvestecOpenApi::Models::Transfer.new(
                        @cheque_account.investec_id,
                        2_000.00,
                        "Moving R2000 to cheque",
                        "Receiving R2000 from savings"
                    )
                ]
            )
        end
    end

    def check_and_transfer_to_savings_if_applicable(available_cheque_balance)
        if available_cheque_balance > 5_000
            amount_to_transfer = ((available_cheque_balance - 4000) / 1000) * 1000
            puts "Transferring R#{amount_to_transfer} to Savings"
            @investec_client.transfer_multiple(
                @cheque_account.investec_id,
                [
                    InvestecOpenApi::Models::Transfer.new(
                        @savings_account.investec_id,
                        amount_to_transfer,
                        "Moving R#{amount_to_transfer} to savings",
                        "Receiving R#{amount_to_transfer} from cheque"
                    )
                ]
            )
        end
    end
end
