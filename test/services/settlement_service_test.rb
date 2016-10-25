require 'test_helper'

require 'helpers/report_service_test_helper'
class SettlementServiceTest < ActiveSupport::TestCase
  include ReportServiceTestHelper

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
    @ss.add_cash_advance(@admin, DateUtils.local_date, amount2, @currency)
    assert @ss.cash_in_hand.value, amount + amount2
    assert @ss.cash_in_hand.currency, @currency
  end

  test 'adding debt clearance' do
    cash_in_hand = @ss.cash_in_hand
    amount = cash_in_hand.value
    if amount == 0
      amount = 500
      assert @ss.add_cash_advance(@admin, DateUtils.local_date, amount, @currency)
      cash_in_hand = @ss.cash_in_hand
      amount = cash_in_hand.value
    end
    assert_equal cash_in_hand.value, amount

    # Adding debt clearance requires initiating user, date, amount value and currency
    assert_not @ss.add_debt_to_company_clearance nil, DateUtils.local_date, amount, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, nil, amount, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, DateUtils.local_date, nil, @currency
    assert @ss.errors.present?
    assert_not @ss.add_debt_to_company_clearance @admin, DateUtils.local_date, amount, @nil
    assert @ss.errors.present?
    assert @ss.add_debt_to_company_clearance @admin, DateUtils.local_date, amount, @currency
    assert @ss.errors.blank?

    amount = 500
    @ss.add_cash_advance(@admin, DateUtils.local_date, amount, @currency)
    assert_equal cash_in_hand.value, amount

    # Can only be cleared by finance manager or admin
    assert_not @ss.add_debt_to_company_clearance(User.find_by(email: 'manager0@finlytest.io'), DateUtils.local_date, amount, @currency)
    assert @ss.errors.present?
    assert_equal cash_in_hand.value, amount
    assert @ss.add_debt_to_company_clearance(@finance, DateUtils.local_date, amount, @currency)
    assert @ss.errors.blank?
    assert_equal cash_in_hand.value, 0

    # Finance manager cannot clear his own debt

    # Amount has to be less than or equal to the employee debt
  end

  test 'computing settlements on report approval' do
    pr = @ss.pending_reimbursement.precision_value
    r = dummy_report_flow @user, final_approve: true
    assert r.approved?
    assert r.controlling_user.blank?
    assert @ss.require_reimbursement? r
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount > 0
    assert_equal pr, @ss.pending_reimbursement.precision_value - report_amount

    old_pr = @ss.pending_reimbursement.precision_value
    r = dummy_report_flow @user, final_approve: true
    pr = @ss.pending_reimbursement.precision_value
    report_amount = ReportDetailService.new(r).total_amount
    assert_equal pr, (old_pr + report_amount).round(2)

    old_pr = @ss.pending_reimbursement.precision_value
    r = dummy_report_flow @user, final_approve: true
    pr = @ss.pending_reimbursement.precision_value
    report_amount = ReportDetailService.new(r).total_amount
    assert_equal pr, (old_pr + report_amount).round(2)

    # Adding a 0 cash advance and submitting a report for 1000 should make the reimbursable amount as 1000 and cash in hand as 0
    # Once calculated, report is marked as accounted
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 0
    amount = 1000
    expected_reimbursable_amount = 1000
    expected_cash_in_advance = 0
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    assert_equal @ss.cash_in_hand.precision_value, expected_cash_in_advance
    assert_equal (old_pr + r.reimbursement_amount.precision_value).round(2), @ss.pending_reimbursement.precision_value

    # Adding a 500 cash advance and submitting a report for 1000 should make the reimbursable amount as 500 and cash in hand as 0
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 500
    amount = 1000
    expected_reimbursable_amount = 500
    expected_cash_in_advance = 0
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    assert_equal @ss.cash_in_hand.precision_value, expected_cash_in_advance
    assert_equal (old_pr + r.reimbursement_amount.precision_value).round(2), @ss.pending_reimbursement.precision_value

    # Adding a 1000 cash advance and submitting a report for 1000 should make the reimbursable amount as 0 and cash in hand as 0
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 1000
    amount = 1000
    expected_reimbursable_amount = 0
    expected_cash_in_advance = 0
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    assert_equal @ss.cash_in_hand.precision_value, expected_cash_in_advance
    assert_equal (old_pr + r.reimbursement_amount.precision_value).round(2), @ss.pending_reimbursement.precision_value

    # Adding a 5000 cash advance and submitting a report for 1000 should make the reimbursable amount as 0 and cash in hand as 4000
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 5000
    amount = 1000
    expected_reimbursable_amount = 0
    expected_cash_in_advance = 4000
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    assert_equal @ss.cash_in_hand.precision_value, expected_cash_in_advance
    assert_equal (old_pr + r.reimbursement_amount.precision_value).round(2), @ss.pending_reimbursement.precision_value

  end

  test 'settlements on report unapproval' do
    # When no cash advance was given prior the expense
    # When recomputed report is marked as unaccounted
    # Reports reimbursement_pending amount is set to 0
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 0
    amount = 1000
    expected_reimbursable_amount = 1000
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    rs = ReportService.new(user: User.find_by(email: 'manager0@finlytest.io'), report: r)
    assert rs.unapprove
    assert_not r.accounted?
    assert_equal @ss.cash_in_hand.precision_value, cash_advance
    assert_equal @ss.pending_reimbursement.precision_value, 0
    assert_equal old_pr.round(2), @ss.pending_reimbursement.precision_value

    # When partial cash advance was given prior to the expense
    assert_equal @ss.cash_in_hand.precision_value, 0
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 500
    amount = 1000
    expected_reimbursable_amount = 500
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    rs = ReportService.new(user: User.find_by(email: 'manager0@finlytest.io'), report: r)
    assert rs.unapprove
    assert_not r.accounted?
    assert_equal @ss.cash_in_hand.precision_value, cash_advance
    assert_equal @ss.pending_reimbursement.precision_value, 0
    assert_equal old_pr.round(2), @ss.pending_reimbursement.precision_value

    # When complete cash advance was given prior to the expenses
    # When a report is processing and accounted, the report total amount is added to cash in hand amount of the user balance sheet
    old_cash_in_hand = 500
    assert_equal @ss.cash_in_hand.precision_value, 500
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 500
    amount = 1000
    expected_reimbursable_amount = 0
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    rs = ReportService.new(user: User.find_by(email: 'manager0@finlytest.io'), report: r)
    assert rs.unapprove
    assert_not r.accounted?
    assert_equal @ss.cash_in_hand.precision_value, old_cash_in_hand + cash_advance
    assert_equal @ss.pending_reimbursement.precision_value, 0
    assert_equal old_pr.round(2), @ss.pending_reimbursement.precision_value

    # When additional cash advance was given prior to the expense
    assert_equal @ss.cash_in_hand.precision_value, 1000
    old_cash_in_hand = 1000
    old_pr = @ss.pending_reimbursement.precision_value
    cash_advance = 1000
    amount = 1000
    expected_reimbursable_amount = 0
    assert @ss.add_cash_advance(@admin, DateUtils.local_date, cash_advance, @currency)
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert r.accounted?
    report_amount = ReportDetailService.new(r).total_amount
    assert report_amount, amount
    assert_equal r.reimbursement_amount.precision_value, expected_reimbursable_amount
    rs = ReportService.new(user: User.find_by(email: 'manager0@finlytest.io'), report: r)
    assert rs.unapprove
    assert_not r.accounted?
    assert_equal @ss.cash_in_hand.precision_value, cash_advance + old_cash_in_hand
    assert_equal @ss.pending_reimbursement.precision_value, 0
    assert_equal old_pr.round(2), @ss.pending_reimbursement.precision_value

    # Computing requires report
    # Can only be recomputed when processing and report is accounted
  end

  test 'adding reimbursement' do
    # When reimbursing amount is less than the total reimbursement amount of the reports
    amount = 2000
    cih = @ss.cash_in_hand.precision_value
    assert_equal cih, 0
    reimbursement_amount = 500
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert_equal r.reimbursement_amount.precision_value, amount
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        assert_not @ss.add_reimbursement(@admin, [r.id], DateUtils.local_date, reimbursement_amount, Currency.first)
      end
    end
    assert r.approved?
    assert @ss.errors.present?
    assert_equal @ss.pending_reimbursement.precision_value, amount

    # When reimbursing amount is greater than the total reimbursement amount of the reports
    old_amount = 2000
    amount = 2000
    cih = @ss.cash_in_hand.precision_value
    assert_equal cih, 0
    reimbursement_amount = 5000
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert_equal r.reimbursement_amount.precision_value, amount
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        assert_not @ss.add_reimbursement(@admin, [r.id], DateUtils.local_date, reimbursement_amount, Currency.first)
      end
    end
    assert r.approved?
    assert @ss.errors.present?
    assert_equal @ss.pending_reimbursement.precision_value, amount + old_amount

    # Successful reimbursement adding reimbursement amount equal to the pending reimbursements
    # Reimbursing a report marks it as reimbursed.
    # Once reimbursed, the payment ID is added to all the reports and the reports are marked as reimbursed
    old_amount = 4000
    amount = 2000
    cih = @ss.cash_in_hand.precision_value
    assert_equal cih, 0
    reimbursement_amount = 2000
    r = dummy_report_flow @user, final_approve: true, amount: amount
    assert_equal r.reimbursement_amount.precision_value, amount
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        assert @ss.add_reimbursement(@admin, [r.id], DateUtils.local_date, reimbursement_amount, Currency.first)
      end
    end
    assert @ss.errors.blank?
    assert_equal @ss.pending_reimbursement.precision_value, old_amount
    r.reload
    assert r.reimbursed?
    assert r.reimbursement.present?


    # When multiple reports are being reimbursed reimbursement amount should match the sum of reimbursable amount of the reports
    reports = @user.reports.approved
    report_ids = reports.pluck(:id)
    old_amount = 4000
    cih = @ss.cash_in_hand.precision_value
    assert_equal cih, 0
    reimbursement_amount = 3000
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count'do
        assert_not @ss.add_reimbursement(@admin, report_ids, DateUtils.local_date, reimbursement_amount, Currency.first)
      end
    end
    assert @ss.errors.present?
    assert_equal @ss.pending_reimbursement.precision_value, old_amount
    reports.each do |report|
      assert report.reload.approved?
      assert report.reimbursement.blank?
    end

    # Can reimburse multiple reports
    reports = @user.reports.approved
    report_ids = reports.pluck(:id)
    old_amount = 4000
    cih = @ss.cash_in_hand.precision_value
    assert_equal cih, 0
    reimbursement_amount = 4000
    assert_difference 'ReportComment.count', report_ids.count do
      assert_difference 'ReportTrack.count', report_ids.count do
        assert @ss.add_reimbursement(@admin, report_ids, DateUtils.local_date, reimbursement_amount, Currency.first)
      end
    end
    assert @ss.errors.blank?
    assert_equal @ss.pending_reimbursement.precision_value, 0
    reports.each do |report|
      assert report.reload.reimbursed?
      assert report.reimbursement.present?
    end

    # Adding reimbursement requires initiating user, date, amount value and currency
    # Can only be added by users final finance manager and admin
    # Report should be selected while adding reimbursement
  end

end