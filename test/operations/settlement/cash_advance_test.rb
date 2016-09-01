require 'test_helper'

class CashAdvanceTest < ActiveSupport::TestCase

  def setup
    @finance = User.find_by(email: 'finance0@finlytest.io')
    @finance3 = User.find_by(email: 'finance2@finlytest.io')
    @employee = User.find_by(email: 'user0@finlytest.io')
    @admin = User.first
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @payment_params = {to_user_id: @employee.id,
                       value: 100,
                       note: "Keep this!",
                       currency_id: 1,
                       date: Date.yesterday }
  end

  test "adding cash advance by finance or admin" do
    add_payment_op = Settlement::AddCashAdvance.new(@admin, @payment_params)
    assert_difference '@employee.payments.count', 1 do
      @payment = add_payment_op.run
    end
    assert @payment
    assert_equal 100, @employee.balance_sheet.cash_in_hand.value


    # finance manager adding cash advance
    add_payment_op = Settlement::AddCashAdvance.new(@finance, @payment_params)
    assert_difference '@employee.payments.count', 1 do
      @payment = add_payment_op.run
    end
    assert @payment
    assert_equal 200, @employee.balance_sheet.reload.cash_in_hand.value
  end

  test "non admins and finance managers who aren't part of the user's mappings can't add money" do
    add_payment_op = Settlement::AddCashAdvance.new(@manager, @payment_params)
    assert_no_difference '@employee.payments.count' do
      begin
        @payment = add_payment_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_equal 0, @employee.balance_sheet.reload.cash_in_hand.value

    # random finance manager trying to add to user's payments
    add_payment_op = Settlement::AddCashAdvance.new(@finance3, @payment_params)
    assert_no_difference '@employee.payments.count' do
      begin
        @payment = add_payment_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert_equal 0, @employee.balance_sheet.reload.cash_in_hand.value

  end

  test "adding invalid parameters to cash advance action" do
    @payment_params[:value] = -10
    add_payment_op = Settlement::AddCashAdvance.new(@admin, @payment_params)
    assert_no_difference '@employee.payments.count' do
      @payment = add_payment_op.run
    end
    assert_not @payment
    assert_not add_payment_op.errors.empty?

    # adding cash advance with future date
    @payment_params[:value] = 100
    @payment_params[:date] = Date.parse('2016-10-03')

    add_payment_op = Settlement::AddCashAdvance.new(@admin, @payment_params)
    assert_no_difference '@employee.payments.count' do
      @payment = add_payment_op.run
    end
    assert_not @payment
    assert_not add_payment_op.errors.empty?

  end


end