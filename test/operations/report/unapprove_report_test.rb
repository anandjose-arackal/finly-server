# require 'test_helper'
# require 'helpers/report_operation_test_helper'
#
# class UnapproveTest < ActiveSupport::TestCase
#
#   include ReportOperationTestHelper
#
#   def setup
#     @admin = User.first
#     @user = User.find_by(email: 'user0@finlytest.io')
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @second_manager = User.find_by(email: 'manager1@finlytest.io')
#     @third_manager = User.find_by(email: 'manager2@finlytest.io')
#     @finance_manager = User.find_by(email: 'finance0@finlytest.io')
#     @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
#   end
#
#   test "report can be unapproved by anyone along the chain of command" do
#     # first employee submits the report
#     assert_difference '@user.reports.count', 1 do
#       @report = create_report(@user)
#     end
#     assert @report
#     assert_equal 5, @report.expenses.count
#     assert_equal ReportStatus.open_id, @report.status_id
#     submit_op = Reports::Submit.new(@user, report_id: @report.id)
#     assert_difference '@user.reports.processing.count', 1 do
#       @report = submit_op.run
#       assert @report
#       assert_equal ReportStatus.processing_id, @report.status_id
#       assert @report.tracks.present?
#     end
#
#     # report approved by manager0, moves to manager1
#     approve_op = Reports::Approve.new(@manager, report_id: @report.id)
#     assert_difference 'ReportTrack.count', 1 do
#       @report = approve_op.run
#     end
#     assert @report
#     assert_equal ReportStatus.processing_id, @report.status_id
#     assert_equal @second_manager.id, @report.controlling_user_id
#
#     # manager1 also approves it, moves to fm0
#     approve_op = Reports::Approve.new(@second_manager, report_id: @report.id)
#     assert_difference 'ReportTrack.count', 1 do
#       @report = approve_op.run
#     end
#     assert @report
#     assert_equal ReportStatus.processing_id, @report.status_id
#     assert_equal @finance_manager.id, @report.controlling_user_id
#
#     # now manager1 should be able to unapprove it, and control return to him
#     unapprove_op = Reports::Unapprove.new(@second_manager, report_id: @report.id)
#     assert_difference 'ReportTrack.count', 1 do
#       @report = unapprove_op.run
#     end
#     assert @report
#     assert_equal ReportStatus.processing_id, @report.status_id
#     assert_equal @second_manager.id, @report.controlling_user_id
#
#
#     # now unapproving by both fm0 or fm1 should fail because they haven't interacted with the report yet
#     unapprove_op = Reports::Unapprove.new(@finance_manager, report_id: @report.id)
#     assert_no_difference 'ReportTrack.count' do
#       @result = unapprove_op.run
#     end
#     assert_not @result
#     assert_equal @second_manager.id, @report.controlling_user_id
#
#     unapprove_op = Reports::Unapprove.new(@second_finance_manager, report_id: @report.id)
#     assert_no_difference 'ReportTrack.count' do
#       @result = unapprove_op.run
#     end
#     assert_not @result
#     assert_equal @second_manager.id, @report.controlling_user_id
#
#   end
#
#   test "users that are not part of the chain of approval cannot unapprove reports" do
#     # first employee submits the report
#     assert_difference '@user.reports.count', 1 do
#       @report = create_report(@user)
#     end
#     assert @report
#     assert_equal 5, @report.expenses.count
#     assert_equal ReportStatus.open_id, @report.status_id
#     submit_op = Reports::Submit.new(@user, report_id: @report.id)
#     assert_difference '@user.reports.processing.count', 1 do
#       @report = submit_op.run
#       assert @report
#       assert_equal ReportStatus.processing_id, @report.status_id
#       assert @report.tracks.present?
#     end
#
#     # unauthorized users trying to unapprove the report
#     unapprove_op = Reports::Unapprove.new(@admin, report_id: @report.id)
#     assert_no_difference 'ReportTrack.count' do
#       @result = unapprove_op.run
#     end
#     assert_not @result
#
#     unapprove_op = Reports::Unapprove.new(User.find_by(email: 'manager3@finlytest.io'), report_id: @report.id)
#     assert_no_difference 'ReportTrack.count' do
#       @result = unapprove_op.run
#     end
#     assert_not @result
#
#   end
#
#   test "Report can only be unapproved in processing or approved state" do
#     # first employee submits the report
#     assert_difference '@user.reports.count', 1 do
#       @report = create_report(@user)
#     end
#     assert @report
#     assert_equal 5, @report.expenses.count
#     assert_equal ReportStatus.open_id, @report.status_id
#     submit_op = Reports::Submit.new(@user, report_id: @report.id)
#     assert_difference '@user.reports.processing.count', 1 do
#       @report = submit_op.run
#       assert @report
#       assert_equal ReportStatus.processing_id, @report.status_id
#       assert @report.tracks.present?
#     end
#
#     # trying to unapprove report before it's even approved
#     unapprove_op = Reports::Unapprove.new(@manager, report_id: @report.id)
#     assert_no_difference 'ReportTrack.count' do
#       @result = unapprove_op.run
#     end
#     assert_not @result
#     assert_not unapprove_op.errors.empty?
#
#     # approving the report till it is in the approved stage
#     Reports::Approve.new(@manager, report_id: @report.id).run
#     Reports::Approve.new(@second_manager, report_id: @report.id).run
#     Reports::Approve.new(@finance_manager, report_id: @report.id).run
#     Reports::Approve.new(@second_finance_manager, report_id: @report.id).run
#
#     @report.reload
#     assert_equal ReportStatus.approved_id, @report.status_id
#
#     # now if the first manager unapproves it, control should return to him in processing state
#     unapprove_op = Reports::Unapprove.new(@manager, report_id: @report.id)
#     assert_difference 'ReportTrack.count', 1 do
#       @report = unapprove_op.run
#     end
#     assert_equal @manager.id, @report.controlling_user_id
#     assert_equal ReportStatus.processing_id, @report.status_id
#   end
#
# end