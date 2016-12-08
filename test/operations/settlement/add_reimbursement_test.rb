# require 'test_helper'
#
# class AddReimbursementTest < ActiveSupport::TestCase
#
#   include MathUtil
#
#   def setup
#     @finance = User.find_by(email: 'finance0@finlytest.io')
#     @finance3 = User.find_by(email: 'finance2@finlytest.io')
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @admin = User.first
#     @approved_reports = @employee.reports.approved.limit(3)
#     @approved_reports_ids = @approved_reports.pluck(:id)
#     @approved_reports_total = @approved_reports.with_amount.sum(:value)
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @reimbursement_params = {to_user_id: @employee.id,
#                              value: @approved_reports_total,
#                              report_ids: @approved_reports_ids,
#                              note: "Keep this!",
#                              currency_id: 1,
#                              date: Date.yesterday }
#
#   end
#
#   test "admin or finance successfully reimbursing reports" do
#
#     assert @employee.balance_sheet.pending_reimbursement_value > 0
#     # old_pending_value = @user.balance_sheet.pending_reimbursement_value
#     add_reimbursement_op = Settlement::Payment::AddReimbursement.new(@admin, @reimbursement_params)
#     assert_difference '@employee.reports.approved.count', -3 do
#       assert_difference '@employee.balance_sheet.pending_reimbursement_value', -precision_value(@approved_reports_total) do
#         @reports = add_reimbursement_op.run
#       end
#     end
#
#     assert @reports
#     @reports.each do |report|
#       assert_equal Report.reimbursed_id, report.status_id
#     end
#     # checking if the users cash in hand is now eqaul to reports reimbursed total
#
#
#   end
# end