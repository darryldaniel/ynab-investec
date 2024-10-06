# frozen_string_literal: true

require "test_helper"

MockBalance = Struct.new(:current_balance)

class MaintainAccountBalanceTest < ActiveSupport::TestCase
    describe "when the savings balance is less than the account balance" do
        it "should do nothing" do
            cheque_account = accounts(:primary)
            savings_account = accounts(:savings)
            investec_client_mock = mock("InvestecOpenApi::Client.new")
            investec_client_mock.expects(:authenticate!)
            investec_client_mock.expects(:balance).with(cheque_account.investec_id)
                                .returns(MockBalance.new(current_balance: 2_000))
            investec_client_mock.expects(:balance).with(savings_account.investec_id)
                                .returns(MockBalance.new(current_balance: 1_000))
            sut = MaintainAccountBalanceService.new investec_client_mock,
                                                    cheque_account,
                                                    savings_account
            sut.run
        end
    end

    describe "when account balance including pending transactions is less than R1000" do
        it "should transfer R2000 from savings" do
            # Arrange

            # Act

            # Assert
        end
    end

    describe "when account balance including pending transactions is more than R2000" do
        it "should transfer the balance - R2000 rounded down to the nearest R1000 to savings" do
            # Arrange


            # Act

            # Assert
        end
    end
end
