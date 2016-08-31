require 'test_helper'
require 'helpers/report_operation_test_helper'

class ApproveTest < ActiveSupport::TestCase

  include ReportOperationTestHelper

  def setup
    @admin = User.first
    @user = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @second_manager = User.find_by(email: 'manager1@finlytest.io')
    @third_manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance0@finlytest.io')
    @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
  end

  test "Report approval flow" do

    # first employee submits the report
    assert_difference '@user.reports.count', 1 do
      @report = create_report(@user)
    end
    assert @report
    assert_equal 5, @report.expenses.count
    assert_equal ReportStatus.open_id, @report.status_id
    submit_op = Report::Submit.new(@user, report_id: @report.id)
    assert_difference '@user.reports.processing.count', 1 do
      @report = submit_op.run
      assert @report
      assert_equal ReportStatus.processing_id, @report.status_id
      assert @report.tracks.present?
    end

    # manager is now the controlling user, so the motherfucker needs to approve it.
    # Report approve will fail unless user and report_id is provided to it
    approve_op = Report::Approve.new(@manager, nil)
    result = approve_op.run
    assert_not result
    assert_not approve_op.errors.empty?
    # this would raise an exception because no user is passed
    begin
      approve_op = Report::Approve.new(nil, report_id: @report.id)
      approve_op.run
    rescue
      rescued = true
    end
    assert rescued

    # correct manager approving the report - the flow this time would be manager0 and then manager1,
    # because manager0's approves to is manager1
    approve_op = Report::Approve.new(@manager, {report_id: @report.id, role_id: UserRole.manager_id})
    assert_difference 'ReportTrack.count', 1 do
      @report = approve_op.run
    end
    assert @report
    assert_equal ReportStatus.processing_id, @report.status_id
    assert_equal @second_manager.id, @report.controlling_user_id

    # report is now being approved by manager1. after manager1, the report should go to finance manager 0
    approve_op = Report::Approve.new(@second_manager, {report_id: @report.id, role_id: UserRole.manager_id})
    assert_difference 'ReportTrack.count', 1 do
      @report = approve_op.run
    end
    assert @report
    assert_equal ReportStatus.processing_id, @report.status_id
    assert_equal @finance_manager.id, @report.controlling_user_id

    # report is now being approved by finance0. the report should now go to finance1,
    # who is the default approves_to for finance0
    approve_op = Report::Approve.new(@finance_manager, {report_id: @report.id, role_id: UserRole.finance_manager_id})
    assert_difference 'ReportTrack.count', 1 do
      @report = approve_op.run
    end
    assert_equal ReportStatus.processing_id, @report.status_id
    assert_equal @second_finance_manager.id, @report.controlling_user_id

    # now finance1 also approves it, who's the final approver, after which it should be
    # accounted for
    approve_op = Report::Approve.new(@second_finance_manager, {report_id: @report.id, role_id: UserRole.finance_manager_id})
    assert_difference 'ReportTrack.count', 1 do
      @report = approve_op.run
    end
    assert @report
    assert_equal ReportStatus.approved_id, @report.status_id
    assert_not @report.controlling_user_id
    assert @report.accounted # i.e. the report has been added to the list of pending reimbursements
    assert @user.balance_sheet.pending_reimbursement_value > 0


    # testing auto approve flow with admin's reports
    assert_difference '@admin.reports.count', 1 do
      @report = create_report(@admin)
      assert @report
      assert_equal 5, @report.expenses.count
      assert_equal 450, @report.total_amount
    end


    # now submitting a report which should get auto approved
    submit_op = Report::Submit.new(@admin, report_id: @report.id)
    assert_difference 'ReportTrack.count', 1 do
      @report = submit_op.run
    end
    assert_equal ReportStatus.approved_id, @report.status_id # not closed because admin has no cash in hand, and still needs to be reimbursed.
    assert @report.comments.present?
    assert_not @report.controlling_user_id

  end

  # test "approval flow for report over 1000" do
  #   # first employee submits the report
  #   assert_difference '@user.reports.count', 1 do
  #     @report = create_report(@user, 1200)
  #   end
  #   assert @report
  #   assert_equal 12, @report.expenses.count
  #   assert_equal ReportStatus.open_id, @report.status_id
  #   submit_op = Report::Submit.new(@user, report_id: @report.id)
  #   assert_difference '@user.reports.processing.count', 1 do
  #     @report = submit_op.run
  #     assert @report
  #     assert_equal ReportStatus.processing_id, @report.status_id
  #     assert @report.tracks.present?
  #   end
  #   debugger
  #
  #   # now manager2 receives the report because amount is greater than 1000 and has to approve it.
  #   approve_op = Report::Approve.new(@finance_manager, report_id: @report.id)
  #   assert_difference 'ReportTrack.count', 1 do
  #     @report = approve_op.run
  #   end
  #   assert @report
  #   assert_equal ReportStatus.processing_id, @report.status_id
  #   # assert_equal @finance_manager.id, @report.controlling_user_id
  #
  #   debugger
  #
  #   approve_op = Report::Approve.new(@finance_manager, report_id: @report.id)
  #   assert_difference 'ReportTrack.count', 1 do
  #     @report = approve_op.run
  #   end
  #   assert @report
  #   assert_equal ReportStatus.processing_id, @report.status_id
  #   assert_equal @second_finance_manager.id, @report.controlling_user_id
  #
  #   approve_op = Report::Approve.new(@second_finance_manager, report_id: @report.id)
  #   assert_difference 'ReportTrack.count', 1 do
  #     @report = approve_op.run
  #   end
  #   assert @report
  #   assert_equal ReportStatus.approved_id, @report.status_id
  #
  #
  # end

  test "invalid person trying to approve reports" do
    # first employee submits the report
    assert_difference '@user.reports.count', 1 do
      @report = create_report(@user)
    end
    assert @report
    assert_equal 5, @report.expenses.count
    assert_equal ReportStatus.open_id, @report.status_id
    submit_op = Report::Submit.new(@user, report_id: @report.id)
    assert_difference '@user.reports.processing.count', 1 do
      @report = submit_op.run
      assert @report
      assert_equal ReportStatus.processing_id, @report.status_id
      assert @report.tracks.present?
    end

    # now different managers other than manager0 try to approve the report.
    approve_op = Report::Approve.new(@admin, nil)
    result = approve_op.run
    assert_not result
    assert_not approve_op.errors.empty?
    # this would raise an exception because no user is passed
    begin
      approve_op = Report::Approve.new(nil, report_id: @report.id)
      approve_op.run
    rescue
      rescued = true
    end
    assert rescued

    approve_op = Report::Approve.new(@second_manager, nil)
    result = approve_op.run
    assert_not result
    assert_not approve_op.errors.empty?
    # this would raise an exception because no user is passed
    begin
      approve_op = Report::Approve.new(nil, report_id: @report.id)
      approve_op.run
    rescue
      rescued = true
    end
    assert rescued

    approve_op = Report::Approve.new(@finance_manager, nil)
    result = approve_op.run
    assert_not result
    assert_not approve_op.errors.empty?
    # this would raise an exception because no user is passed
    begin
      approve_op = Report::Approve.new(nil, report_id: @report.id)
      approve_op.run
    rescue
      rescued = true
    end
    assert rescued
  end
end