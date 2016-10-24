require 'test_helper'

require 'helpers/report_service_test_helper'
class ReportServiceTest < ActiveSupport::TestCase
  include ReportServiceTestHelper

  def setup

  end

  test 'creating new report' do
    report = nil
    user = User.last

    report_service = ReportService.new
    # Cannot create reports without user
    assert_no_difference 'Report.count' do
      assert_no_difference 'ReportTrack.count' do
        report = report_service.create
      end
    end
    assert report.blank?
    assert report_service.errors.present?

    # Successful creation
    assert_difference 'Report.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        report = ReportService.new(user: user).create
      end
    end
    assert report.present?
    assert report.is_a?(Report)
    assert_equal report.user.id, user.id
    assert report.name.present?
    assert report.status.id == ReportStatus.open_id

    # Can create report with a report name
    # Can create report with expenses pre-selected
  end

  test 'adding expenses to reports' do
    user = User.last
    report_service = ReportService.new(user: user)
    report = report_service.create
    assert report.present?

    report_service = ReportService.new(user: user, report: report)
    expense_service = ExpenseService.new(user)
    expenses = []
    assert_difference 'Expense.count', 5 do
      5.times.each do
        expenses << expense_service.add_expense(expense: {amount: Faker::Commerce.price, merchant: Faker::Company.name, expense_status_id: 1,
                                                          expense_type_id: 1, date: DateUtils.local_date, currency_id: 1})
      end
    end
    assert_equal expenses.size, 5
    expenses.each do |expense|
      assert_nil expense.report_id
    end
    expenses = user.expenses.unreported
    report_service.add_expense(expenses)
    expenses.each do |expense|
      expense.reload
      assert_equal expense.report.id, report.id
    end

    # Only report owners can add expenses to report
    # Expenses can be added to report only when report is in open or retracted states
    # Expenses when added to report should clear manager memo and rejecting manager id
  end

  test 'removing expenses from report' do

  end

  test 'rejectable to users list' do

  end

  test 'next reviewer for report' do
    user = User.find_by(email: 'user0@finlytest.io')
    r = ReportService.new(user: user).create
    assert_equal 'manager0@finlytest.io', ReportService.new(user: user, report: r).next_reviewer_for_report.email
    add_dummy_expenses(user, r)
    ReportService.new(user: user, report: r).submit
    assert r.processing?
    assert_equal 'manager1@finlytest.io', ReportService.new(user: r.controlling_user, report: r).next_reviewer_for_report.email
    ReportService.new(user: r.controlling_user, report: r).approve
    assert r.processing?
    assert_equal 'finance0@finlytest.io', ReportService.new(user: r.controlling_user, report: r).next_reviewer_for_report.email
    ReportService.new(user: r.controlling_user, report: r).approve
    assert r.processing?
    assert_equal 'finance1@finlytest.io', ReportService.new(user: r.controlling_user, report: r).next_reviewer_for_report.email
    ReportService.new(user: r.controlling_user, report: r).approve
    assert r.processing?
    assert ReportService.new(user: r.controlling_user, report: r).next_reviewer_for_report.blank?
    ReportService.new(user: r.controlling_user, report: r).approve
    assert r.approved?
    assert r.controlling_user.blank?
  end

  test 'report submission' do
    user = User.last

    report_service = ReportService.new(user: user)
    report = report_service.create

    # Reports can only be submitted if they have atleast one expense
    report_service = ReportService.new(user: User.first, report: report)
    assert report.expenses.blank?
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    add_dummy_expenses(user, report)

    # Report service submission will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # Report service submission will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # Only the report owner can submit the report
    report_service = ReportService.new(user: User.first, report: report)
    assert report.open?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report.open?
    assert report_service.errors.present?

    # Successful submission with memo
    report_service = ReportService.new(user: user, report: report)
    assert report.open?
    memo = 'test memo l'
    assert_difference 'ReportTrack.count', 1 do
      report_service.submit(memo: memo)
    end
    report = report.reload
    report.tracks.reload
    assert report.processing?
    assert_equal report.memo, memo
    assert_equal report.tracks.last.memo, memo
    assert report_service.errors.blank?

    # Report can only be submitted in open/retracted state
    report_service = ReportService.new(user: user, report: report)
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # If report is submitted by a user who does not have a manager, it is auto approved

    # Submitting report should mark all expenses as submitted
  end

  test 'report retract flow' do
    user = User.last

    report = dummy_report_flow(user, submit: true)
    assert report.processing?
    assert_not_equal report.controlling_user.id, report.user.id

    # Report service retract will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report service retract will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report can only be retracted by the user
    report_service = ReportService.new(report: report, user: report.controlling_user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Successful retract
    report_service = ReportService.new(report: report, user: report.user)
    assert report_service.errors.blank?
    assert_difference 'ReportTrack.count', 1 do
      report_service.retract
    end
    assert report_service.errors.blank?
    assert report.retracted?

    # Report can only be retracted when in processing states
    assert report.retracted?
    report_service = ReportService.new(report: report, user: report.user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report_service.errors.present?
    assert report.retracted?

    # Retracting report should mark all expenses as unsubmitted
  end

  test 'report approve flow' do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    controlling_user = report.controlling_user
    assert report.present?
    assert report.processing?

    # Report service approve will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report service approve will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be approved by controlling manager
    report_service = ReportService.new(user: User.first, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be approved when in processing state
    r = dummy_report_flow user, create: true
    rs = ReportService.new(user: controlling_user, report: r)
    assert rs.errors.blank?
    assert r.open?
    assert_no_difference 'ReportTrack.count' do
      rs.approve
    end
    assert r.open?
    assert rs.errors.present?

    # Successful approval
    # After approval, if approving manager has a approves_to, report is still in processing state approves_to manager is assigned as the controlling manager
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert_not_equal report.controlling_user.id, controlling_user.id
    assert report_service.errors.blank?
    assert report.processing?
    approves_to = UserTeamService.new(controlling_user).approves_to(view: 'manager', report: report)
    assert approves_to.present?
    assert report.controlling_user.id, approves_to.id

    # After approval, if approving manager does not have approves_to assigned, report is still in processing state and finance manager is assigned as controlling manager
    assert report.processing?
    report_service = ReportService.new(user: approves_to, report: report)
    assert report_service.errors.blank?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert report.processing?
    finance_manager = UserTeamService.new(report.user).finance_manager(report: report)
    assert finance_manager.present?
    assert report.controlling_user.id, finance_manager.id

    # After finance approval, if approving manager has a finance_approves_to, report is still in processing state finance_approves_to manager is assigned as the controlling manager
    controlling_user = report.controlling_user
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert_not_equal report.controlling_user.id, controlling_user.id
    assert report_service.errors.blank?
    assert report.processing?
    approves_to = UserTeamService.new(controlling_user).approves_finance_to(view: 'manager', report: report)
    assert approves_to.present?
    assert report.controlling_user.id, approves_to.id

    # After final finance approval, report is marked as approved
    controlling_user = report.controlling_user
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert report.controlling_user.blank?
    assert report_service.errors.blank?
    assert report.approved?

    # When auto-approval due to no manager or finance manager assigned, report is marked as approved and controlling user is set to nil
    u = User.first
    r = dummy_report_flow u, create_and_add_expenses: true
    assert UserTeamService.new(u).manager(report: r).blank?
    rs = ReportService.new(user: u, report: r)
    rs.submit
    assert r.approved?

    # After final approval, if the user does not have a finance manager assigned, report is set to approved state and left hanging for admin to take control
    assert r.controlling_user.blank?

    # When report is approved, if report contains reimbursable expenses, final finance manager is set as the controlling user of the report
    # When report is approved, if final approver is not a finance manager and report contains reimbursable expenses, reports controlling user is set as nil
    # Auto approval should set the tracking status as auto-approved and have nil as action_user
    # todo track action ids verification
  end

  test 'test reject flow' do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    assert report.present?
    assert report.processing?
    ReportService.new(user: report.controlling_user, report: report).approve
    ReportService.new(user: report.controlling_user, report: report).approve

    # Report service reject will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.reject report.user
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report service reject will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.reject report.user
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be rejected by controlling manager
    report_service = ReportService.new(user: User.first, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.reject report.user
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be rejected when in processing state
    u = User.find_by(email: 'user0@finlytest.io')
    r = dummy_report_flow u, final_approve: true
    assert r.controlling_user.blank?
    rs = ReportService.new(user: User.find_by(email: 'finance1@finlytest.io'), report: r)
    assert r.approved?
    assert_no_difference 'ReportTrack.count' do
      rs.reject r.user
    end
    assert r.approved?
    assert rs.errors.present?

    # Successful rejection with memo
    # If no user is selected while rejecting, report is rejected back to the report owner
    # If report is rejected back to report owner, report is set to rejected state and all expenses are set to unsubmitted state
    report_service = ReportService.new(user: report.controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert report.expenses.first.submitted?
    memo = 'test memo'
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        report_service.reject nil, memo
      end
    end
    assert report.rejected?
    assert report.expenses.first.unsubmitted?
    assert_equal report.controlling_user_id, report.user.id
    assert_equal report.memo, memo
    assert report_service.errors.blank?

    # Can be rejected to anyone in the chain of users who interacted with the report
    # If report is rejected back to a manager, report is set to processing state
    # After rejection report controlling user is marked as the person report was rejected to
    report = dummy_report_flow user, submit: true
    assert report.processing?
    ReportService.new(user: report.controlling_user, report: report).approve
    ReportService.new(user: report.controlling_user, report: report).approve
    rs = ReportService.new(user: report.controlling_user, report: report)
    rejectable_users = rs.rejectable_to_users
    assert_equal rejectable_users.size, 3
    memo = 'memo number 2'
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        rs.reject(rejectable_users.second, memo)
      end
    end
    assert report.processing?
    assert_equal report.controlling_user.id, rejectable_users.second.id
    assert_equal report.memo, memo

    # Rejecting report should generate respective mailers and comments
  end

  test 'test unapprove flow' do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    assert report.present?
    assert report.processing?
    ReportService.new(user: report.controlling_user, report: report).approve
    ReportService.new(user: report.controlling_user, report: report).approve

    # Can only be unapproved in processing state or in approved state
    r = dummy_report_flow user, create: true
    u = User.find_by(email: 'manager1@finlytest.io')
    assert r.open?
    rs = ReportService.new(user: u, report: r)
    assert rs.rejectable_to_users.blank?
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        rs.unapprove
      end
    end
    assert r.open?
    assert rs.errors.present?

    # Can only be unapproved by managers and only if it was previously approved by the manager
    r = dummy_report_flow user, submit: true
    u = User.find_by(email: 'finance0@finlytest.io')
    assert r.processing?
    rs = ReportService.new(user: u, report: r)
    assert rs.rejectable_to_users.present?
    assert rs.rejectable_to_users.with_id(u.id).blank?
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        rs.unapprove
      end
    end
    assert r.processing?
    assert rs.errors.present?

    # Successful unapprove
    # Report status is set to processing when unapproved
    # When unapproved controlling user is updated to the unapproving user
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    assert report.present?
    assert report.processing?
    ReportService.new(user: report.controlling_user, report: report).approve
    ReportService.new(user: report.controlling_user, report: report).approve

    assert report.processing?
    rs = ReportService.new(user: report.controlling_user, report: report)
    assert rs.rejectable_to_users.present?
    unapproving_user = rs.rejectable_to_users.second
    rs = ReportService.new(user: unapproving_user, report: report)
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        rs.unapprove
      end
    end
    assert report.processing?
    assert rs.errors.blank?
    assert_equal report.controlling_user.id, unapproving_user.id

    # Unapproving report in approved state
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, final_approve: true

    assert report.approved?
    rs = ReportService.new(user: report.controlling_user, report: report)
    assert rs.rejectable_to_users.blank?
    unapproving_user = report.associated_users.second
    rs = ReportService.new(user: unapproving_user, report: report)
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        rs.unapprove
      end
    end
    assert report.processing?
    assert rs.errors.blank?
    assert_equal report.controlling_user.id, unapproving_user.id
  end

  # test 'reimburse flow' do
  #   user = User.find_by email: 'user0@finlytest.io'
  #
  #   # Can only be reimbursed once approved
  #   report = dummy_report_flow user, submit: true
  #   rs = ReportService.new user: report.controlling_user, report: report
  #   assert report.processing?
  #   assert_no_difference 'ReportComment.count' do
  #     assert_no_difference 'ReportTrack.count' do
  #       rs.reimburse
  #     end
  #   end
  #   assert report.processing?
  #   assert rs.errors.present?
  #
  #   # Can only be reimbursed by the final finance manager
  #   report = dummy_report_flow user, final_approve: true
  #   rs = ReportService.new user: User.find_by(email: 'finance0@finlytest.io'), report: report
  #   assert report.approved?
  #   assert_no_difference 'ReportComment.count' do
  #     assert_no_difference 'ReportTrack.count' do
  #       rs.reimburse
  #     end
  #   end
  #   assert report.approved?
  #   assert rs.errors.present?
  #
  #   # Can only reimburse if the report has reimbursable expenses in it
  #   report = dummy_report_flow user, final_approve: true
  #   rs = ReportService.new user: User.find_by(email: 'finance1@finlytest.io'), report: report
  #   assert report.approved?
  #   assert_no_difference 'ReportComment.count' do
  #     assert_no_difference 'ReportTrack.count' do
  #       rs.reimburse
  #     end
  #   end
  #   assert report.approved?
  #   assert rs.errors.present?
  #
  #   # Successful reimbursement
  #   # After reimbursement, reports controlling user is report owner
  #   # Can add a memo while reimbursing the report
  #   # Once reimbursed report is marked as reimbursed
  #   report = dummy_report_flow user, final_approve: true
  #   rs = ReportService.new user: User.find_by(email: 'finance1@finlytest.io'), report: report
  #   assert report.approved?
  #   memo = 'test memo reimburse'
  #   assert_difference 'ReportComment.count', 1 do
  #     assert_difference 'ReportTrack.count', 1 do
  #       rs.reimburse memo: memo
  #     end
  #   end
  #   assert report.reimbursed?
  #   assert rs.errors.blank?
  #   assert_equal report.controlling_user.id, report.user.id
  #
  # end
  #
  # test 'reimburse_confirm flow' do
  #
  # end

  test 'delete_report flow' do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    rs = ReportService.new(user: user, report: report)
    # Report can only be delted in open or retracted view
    assert report.processing?
    rs = ReportService.new(user: user, report: report)
    assert_no_difference 'ReportTrack.count' do
      assert_no_difference 'ReportComment.count' do
        rs.delete_report
      end
    end
    assert report.processing?
    assert rs.errors.present?

    rs.retract
    assert report.retracted?
    assert rs.errors.blank?

    # Report can only be deleted by its owner
    rs = ReportService.new(user: User.find_by(email: 'manager0@finlytest.io'), report: report)
    assert report.retracted?
    assert_no_difference 'ReportTrack.count' do
      assert_no_difference 'ReportComment.count' do
        rs.delete_report
      end
    end
    assert report.retracted?
    assert rs.errors.present?

    # Successful retract
    # When a report is deleted, all expenses are moved to unreported state
    rs = ReportService.new(user: user, report: report)
    id = report.id
    expenses = report.expenses
    assert report.retracted?
    assert_difference 'ReportTrack.count', -(report.tracks.count) do
      assert_difference 'ReportComment.count', -(report.comments.count) do
        rs.delete_report
      end
    end
    assert user.reports.with_id(id).blank?
    assert rs.errors.blank?
    expenses.reload
    expenses.each do |expense|
      assert expense.report_id.blank?
    end
  end

  test 'archive_report flow' do
    # Report can only be archived by the user
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, final_approve: true
    rs = ReportService.new(user: report.controlling_user, report: report)
    assert report.approved?
    rs.archive_report
    assert rs.errors.present?
    assert report.approved?

    # Report can only be archived when once approved
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    rs = ReportService.new(user: user, report: report)
    assert report.processing?
    rs.archive_report
    assert rs.errors.present?
    assert report.processing?

    # todo Archiving a report sets it status as archived. Can be done after settlements and reimbursements
    # user = User.find_by(email: 'user0@finlytest.io')
    # report = dummy_report_flow user, final_approve: true
    # rs = ReportService.new(user: user, report: report)
    # assert report.approved?
    # assert rs.archive_report
    # assert rs.errors.blank?
    # assert report.archived?
  end

  test 'take_control flow' do
    # Only admins and policy admins can take control of the report
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    controlling_user = report.controlling_user
    m1 = User.find_by(email: 'manager1@finlytest.io')
    rs = ReportService.new(user: m1, report: report)
    assert report.processing?
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        rs.take_control
      end
    end
    assert_not_equal m1.id, report.controlling_user.id
    assert_equal controlling_user.id, report.controlling_user.id
    assert rs.errors.present?

    admin= User.find_by(email: 'admin@finlytest.io')

    # Admins can take control of report only when its in processing state
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, final_approve: true
    rs = ReportService.new(user: admin, report: report)
    assert report.approved?
    assert_no_difference 'ReportComment.count' do
      assert_no_difference 'ReportTrack.count' do
        rs.take_control
      end
    end
    assert report.approved?
    assert rs.errors.present?

    # Admin can take control of the report for the controlling_user only
    # Once admin takes control, controlling user is assigned as the admin and controlling_for user is assigned as the original_controlling_user
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    rs = ReportService.new(user: admin, report: report)
    controlling_user = report.controlling_user
    assert report.processing?
    assert_difference 'ReportComment.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        rs.take_control
      end
    end
    assert report.processing?
    assert_equal report.controlling_for_user.id,controlling_user.id
    assert report.controlling_user.id, admin.id
    assert rs.errors.blank?
    rs.approve
    assert report.controlling_user.email, 'manager1@finlytest.io'
  end

  # todo test comments
  # todo test expense rejection

end
