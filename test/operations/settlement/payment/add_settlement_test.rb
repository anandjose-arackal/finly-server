require 'test_helper'

class AddSettlementTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @report = Report.first
    @reports = Report.with_id(@report)
    @user = @company.users.first
    @to_user = @company.users.second
    @initiating_card = Card.first
    @report.stubs(:user).returns(@to_user)
    @reports.stubs(:with_cash_expenses_total => stub(:sum => '200'))
    @user.stubs(:company => stub(:users => stub(:with_id => stub(:first => @to_user))))
    @to_user.stubs(:reports => stub(:with_id => @reports))
    @user.stubs(:valid_password?).returns(true)
    User::Team::Index.stubs(:call => stub(:success? => true, :include? => true))
  end

  test 'successful settlement with just deduction of cash on hand' do
    deduction_amount = 100
    @to_user.balance_sheet.expects(:subtract_cash_in_hand).with(deduction_amount).returns(true)

    params = {id: @to_user.id, report_ids: @reports, password: 'asd',
              payment: {from_cash_in_hand: "#{deduction_amount}", date: Date.today}, view: 'finance'}
    result = Settlement::Payment::AddSettlement.(@user, params)
    assert result.success?
  end

  test 'successful settlement with reimbursement' do

  end

  test 'successful settlement with reimbursement and deduction of cash on hand' do

  end

  test 'successful settlement with additional settlement outside finly' do
    deduction_amount = 100
    settle_outside_finly_amount = 50
    @to_user.balance_sheet.expects(:subtract_cash_in_hand).with(deduction_amount).returns(true)

    params = {id: @to_user.id, report_ids: @reports, password: 'asd',
              payment: {from_cash_in_hand: "#{deduction_amount}", date: Date.today,
                        from_outside_finly: settle_outside_finly_amount},
              view: 'finance'}
    assert_difference 'Payment.count', 1 do
      result = Settlement::Payment::AddSettlement.(@user, params)
    end
    assert result.success?
    assert result.payment.present?
    assert_equal result.payment.payment_type_id, PaymentType.id_for(:reimbursement_outside_finly)
    assert_equal result.payment.amount.value, settle_outside_finly_amount
  end

end