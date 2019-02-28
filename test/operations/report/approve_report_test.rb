# require 'test_helper'
# require 'helpers/report_operation_test_helper'
#
# class ApproveTest < ActiveSupport::TestCase
#
#   def setup
#     @admin = User.first
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @second_manager = User.find_by(email: 'manager1@finlytest.io')
#     @third_manager = User.find_by(email: 'manager2@finlytest.io')
#     @finance_manager = User.find_by(email: 'finance0@finlytest.io')
#     @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
#     @report = Report.first # this needs to be in open state
#   end
#
#   test "successful approval of the report that does not have a next reviewer" do
#     # stubbing the state of the report as processing
#     Report.any_instance.stubs(:processing?).returns(true)
#     Report.any_instance.stubs(:controlling_user_id).returns(@admin.id)
#     Report.any_instance.stubs(:controlling_user?).returns(true)
#     # stubbing the attr_accessor within the approve operation
#     Reports::Approve.any_instance.stubs(:report).returns(@report)
#     # stubbing next reviewer
#     next_reviewer_presenter = User::Team::Review::NextReviewer::Presenter.new(nil, role_id: nil)
#     User::Team::Review::NextReviewer.stubs(:call).returns(next_reviewer_presenter)
#
#     approve_op = Reports::Approve.new(@admin, {id: @report.id, view: "admin"})
#     assert_difference 'Report.approved.count', 1 do
#       @result = approve_op.run
#       @report.reload
#     end
#     assert @result.success?
#     assert_equal ReportStatus.approved_id, @report.report_status_id
#     assert_not @report.controlling_user
#   end
#
#   test "successful approval of a report through explicitly passing auto approve to the operation" do
#
#   end
#
#   test "successful approval of a report that has a next reviewer" do
#     # stubbing the state of the report as processing
#     Report.any_instance.stubs(:processing?).returns(true)
#     Report.any_instance.stubs(:controlling_user_id).returns(@admin.id)
#     Report.any_instance.stubs(:controlling_user?).returns(true)
#     # stubbing the attr_accessor within the report and the next reviewer
#     Reports::Approve.any_instance.stubs(:report).returns(@report)
#     next_reviewer_presenter = User::Team::Review::NextReviewer::Presenter.new(@manager, role_id: UserRole.id_for(:manager))
#     User::Team::Review::NextReviewer.stubs(:call).returns(next_reviewer_presenter)
#
#     approve_op = Reports::Approve.new(@admin, {id: @report.id, view: "admin"})
#     assert_difference 'Report.processing.count', 1 do
#       @result = approve_op.run
#     end
#     assert @result.success?
#     assert_equal ReportStatus.processing_id, @report.report_status_id
#     assert_equal @manager.id, @result.report.controlling_user.id
#
#   end
#
#   test "successful approval of a report that doesn't have a reimbursement amount and no next reviewer" do
#     # stubbing the state of the report as processing
#     Report.any_instance.stubs(:processing?).returns(true)
#     Report.any_instance.stubs(:controlling_user_id).returns(@admin.id)
#     Report.any_instance.stubs(:controlling_user?).returns(true)
#     Report.any_instance.stubs(:require_reimbursement?).returns(false)
#     # stubbing the attr_accessor within the report and the next reviewer
#     Reports::Approve.any_instance.stubs(:report).returns(@report)
#     next_reviewer_presenter = User::Team::Review::NextReviewer::Presenter.new(nil, role_id: nil)
#     User::Team::Review::NextReviewer.stubs(:call).returns(next_reviewer_presenter)
#
#     approve_op = Reports::Approve.new(@admin, {id: @report.id, view: "admin"})
#     assert_difference 'Report.closed.count', 1 do
#       @result = approve_op.run
#     end
#     assert @result.success?
#     assert_equal ReportStatus.closed_id, @report.report_status_id
#     assert_not @result.report.controlling_user
#   end
#
#   test "successful auto approval of a report through the params" do
#
#   end
#
#   test "cannot approve a report that's not in processing state" do
#     # stubbing the state of the report as processing
#     Report.any_instance.stubs(:processing?).returns(false)
#     Report.any_instance.stubs(:controlling_user_id).returns(@admin.id)
#     Report.any_instance.stubs(:controlling_user?).returns(true)
#
#     # stubbing the attr_accessor within the report and the next reviewer
#     Reports::Approve.any_instance.stubs(:report).returns(@report)
#     next_reviewer_presenter = User::Team::Review::NextReviewer::Presenter.new(nil, role_id: nil)
#     User::Team::Review::NextReviewer.stubs(:call).returns(next_reviewer_presenter)
#
#     approve_op = Reports::Approve.new(@admin, {id: @report.id, view: "admin"})
#     assert_no_difference 'Report.open.count' do
#       @result = approve_op.run
#     end
#     assert_not @result.success?
#     assert_not @result.messages[:error].empty?
#     assert_equal ReportStatus.open_id, @report.report_status_id
#
#   end
#
#   test "cannot approve a report unless you're the controlling user" do
#     # stubbing the state of the report as processing
#     Report.any_instance.stubs(:processing?).returns(true)
#     Report.any_instance.stubs(:controlling_user_id).returns(@manager.id)
#     Report.any_instance.stubs(:controlling_user?).returns(true)
#
#     # stubbing the attr_accessor within the report
#     Reports::Approve.any_instance.stubs(:report).returns(@report)
#
#     approve_op = Reports::Approve.new(@admin, {id: @report.id, view: "admin"})
#     assert_no_difference 'Report.open.count' do
#       begin
#         @result = approve_op.run
#       rescue NotAuthorizedException
#         @rescued = true
#       end
#     end
#     assert @rescued
#     assert_equal ReportStatus.open_id, @report.report_status_id
#   end
#
#
# end