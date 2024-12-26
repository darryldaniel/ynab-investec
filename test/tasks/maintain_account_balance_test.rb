# frozen_string_literal: true

require "test_helper"

MockMoney = Struct.new(:cents)
MockBalance = Struct.new(:current_balance, :available_balance)

class MaintainAccountBalanceTest < ActiveSupport::TestCase
    setup do
        @cheque_account = accounts(:primary)
        @savings_account = accounts(:savings)
        @investec_client_mock = mock("InvestecOpenApi::Client.new")
        @investec_client_mock.expects(:authenticate!)
    end

    describe "when the savings current balance is less than the account available balance - R50000" do
        it "should do nothing" do
            @investec_client_mock.expects(:balance).with(@cheque_account.investec_id)
                                 .returns(
                                     get_mock_balance(
                                         52_000,
                                         2_000
                                     )
                                 )
            @investec_client_mock.expects(:balance).with(@savings_account.investec_id)
                                 .returns(
                                     get_mock_balance(
                                         1_000,
                                         1_000
                                     )
                                 )
            sut = create_service
            sut.run
        end
    end

    describe "when the cheque available balance is less than R 51,000" do
        it "should transfer R2000 from savings" do
            @investec_client_mock.expects(:balance).with(@cheque_account.investec_id)
                                 .returns(
                                     get_mock_balance(
                                         50_500,
                                         2_000
                                     )
                                 )
            @investec_client_mock.expects(:balance).with(@savings_account.investec_id)
                                 .returns(
                                     get_mock_balance(
                                         10_000,
                                         10_000
                                     )
                                 )
            mock_transfer = mock
            InvestecOpenApi::Models::Transfer.expects(:new)
                                             .with(
                                                 @cheque_account.investec_id,
                                                 2_000.00,
                                                 "Moving R2000 to cheque",
                                                 "Receiving R2000 from savings"
                                             )
                                             .returns(mock_transfer)
            @investec_client_mock.expects(:transfer_multiple)
                                 .with(
                                     @savings_account.investec_id,
                                     [mock_transfer]
                                 )
            sut = create_service
            sut.run
        end

        describe "and the savings balance is less than R2000" do
            it "should do nothing" do
                @investec_client_mock.expects(:balance).with(@cheque_account.investec_id)
                                     .returns(
                                         get_mock_balance(
                                             50_500,
                                             2_000
                                         )
                                     )
                @investec_client_mock.expects(:balance).with(@savings_account.investec_id)
                                     .returns(
                                         get_mock_balance(
                                             1_000,
                                             1_000
                                         )
                                     )
                mock_transfer = mock
                sut = create_service
                sut.run
            end
        end
    end

    describe "when the cheque balance is between R51,000 and R52,000" do
        it "should transfer R2000 from savings" do
            mock_cheque_balance(51_600, 1_600)
            mock_savings_balance(20_000, 20_000)
            mock_transfer = mock
            InvestecOpenApi::Models::Transfer.expects(:new)
                                             .with(
                                                 @cheque_account.investec_id,
                                                 2_000.00,
                                                 "Moving R2000 to cheque",
                                                 "Receiving R2000 from savings"
                                             )
                                             .returns(mock_transfer)
            @investec_client_mock.expects(:transfer_multiple)
                                 .with(
                                     @savings_account.investec_id,
                                     [mock_transfer]
                                 )
            sut = create_service
            sut.run
        end
    end

    describe "when the cheque available balance is more than R 55,000" do
        it "should transfer the available balance - R 54,000 rounded down to the nearest R1000 to savings" do
            mock_cheque_balance(56_500, 7_000)
            mock_savings_balance(20_000, 20_000)
            mock_transfer = mock
            InvestecOpenApi::Models::Transfer.expects(:new)
                                             .with(
                                                 @savings_account.investec_id,
                                                 2_000.00,
                                                 "Moving R2000 to savings",
                                                 "Receiving R2000 from cheque"
                                             )
                                             .returns(mock_transfer)
            @investec_client_mock.expects(:transfer_multiple)
                                 .with(
                                     @cheque_account.investec_id,
                                     [mock_transfer]
                                 )
            sut = create_service
            sut.run
        end
    end

    describe "when the cheque available balance is less than R50,000" do
        it "should move enough money from savings to make the balance above R52,000" do
            mock_cheque_balance(46_600, -3_400)
            mock_savings_balance(20_000, 20_000)
            mock_transfer = mock
            InvestecOpenApi::Models::Transfer.expects(:new)
                                             .with(
                                                 @cheque_account.investec_id,
                                                 6_000.00,
                                                 "Moving R6000 to cheque",
                                                 "Receiving R6000 from savings"
                                             )
                                             .returns(mock_transfer)
            @investec_client_mock.expects(:transfer_multiple)
                                 .with(
                                     @savings_account.investec_id,
                                     [mock_transfer]
                                 )
            sut = create_service
            sut.run
        end
    end

    def create_service
        MaintainAccountBalanceService.new @investec_client_mock,
                                          @cheque_account,
                                          @savings_account
    end

    def mock_cheque_balance(available_balance, current_balance)
        @investec_client_mock.expects(:balance).with(@cheque_account.investec_id)
                             .returns(
                                 get_mock_balance(
                                     available_balance,
                                     current_balance
                                 )
                             )
    end

    def mock_savings_balance(available_balance, current_balance)
        @investec_client_mock.expects(:balance).with(@savings_account.investec_id)
                             .returns(
                                 get_mock_balance(
                                     available_balance,
                                     current_balance
                                 )
                             )
    end

    def get_mock_balance(
        available_in_rand,
        current_in_rand
    )
        MockBalance.new(
            current_balance: MockMoney.new(cents: current_in_rand * 100),
            available_balance: MockMoney.new(cents: available_in_rand * 100)
        )
    end
end
