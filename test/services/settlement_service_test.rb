require 'test_helper'

class SettlementServiceTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @user= User.find_by(email: 'user0@finlytest.io')
    @finance = User.find_by(email: 'finance0@finlytest.io')
    @ss = SettlementService.new(@user)
    @currency = Currency.first
  end

  test 'adding cash advance' do
    # Adding requires initiating user, date, amount value and currency
    # Can only be added by user's final finance manager and admin
    assert_equal @ss.cash_in_hand.value, 0
    amount = 500.50
    @ss.add_cash_advance(@admin, Date.yesterday, amount, @currency)
    assert @ss.cash_in_hand.value, amount
    assert @ss.cash_in_hand.currency, @currency

    amount2 = 120
    @ss.add_cash_advance(@admin, Date.today, amount2, @currency)
    assert @ss.cash_in_hand.value, amount + amount2
    assert @ss.cash_in_hand.currency, @currency
  end

  test 'adding debt clearance' do
    cash_in_hand = @ss.cash_in_hand
    amount = cash_in_hand.value
    if amount == 0
      amount = 500
      assert @ss.add_cash_advance(@admin, Date.today, amount, @currency)
      cash_in_hand = @ss.cash_in_hand
      amount = cash_in_hand.value
    end
    assert_equal cash_in_hand.value, amount

    # Adding debt clearance requires initiating user, date, amount value and currency
    assert_not @ss.add_debt_to_company_clearance nil, Date.today, amount, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, nil, amount, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, Date.today, nil, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, Date.today, amount, @nil
    assert @ss.errors.present?
    assert @ss.add_debt_to_company_clearance @admin, Date.today, amount, @currency
    assert @ss.errors.blank?

    amount = 500
    @ss.add_cash_advance(@admin, Date.today, amount, @currency)
    assert_equal cash_in_hand.value, amount

    # Can only be cleared by finance manager or admin
    assert_not @ss.add_debt_to_company_clearance(User.find_by(email: 'manager0@finlytest.io'), Date.today, amount, @currency)
    assert @ss.errors.present?
    assert_equal cash_in_hand.value, amount
    assert @ss.add_debt_to_company_clearance(@finance, Date.today, amount, @currency)
    assert @ss.errors.blank?
    assert_equal cash_in_hand.value, 0

    # Finance manager cannot clear his own debt

    # Amount has to be less than or equal to the employee debt
  end

  test 'computing settlements on report approval' do
    # Computing requires report
    # Can only be recomputed when approved and the report is unaccounted
    # When a report is approved and unaccounted, the cash in hand is deducted from the total amount
    # If cash_in_hand - total_amount is negative, the difference is added as pending reimbursements to balance sheet
    # Once calculated, report is marked as accounted
  end

  test 'settlements on report unapproval' do
    # Computing requires report
    # Can only be recomputed when processing and report is accounted
    # When a report is processing and accounted, the report total amount is added to cash in hand amount ofthe user balance sheet
    # Reports reimbursement_pending amount is set to 0
    # When recomputed report is marked as unaccounted
  end

  test 'adding reimbursement' do
    # Adding reimbursement requires initiating user, date, amount value and currency
    # Can only be added by users final finance manager and admin
    # Report should be selected while adding reimbursement
    # Reimbursement amount should always be equal to the the sum of pending reimbursement amount of the selected reports
    # Once reimbursed, the payment ID is added to all the reports and the reports are marked as reimbursed
  end

end