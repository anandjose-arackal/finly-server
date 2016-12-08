# require 'test_helper'
#
# class ReimburseTest < ActiveSupport::TestCase
#
#
#   def setup
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @second_manager = User.find_by(email: 'manager1@finlytest.io')
#     @finance = User.find_by(email: 'finance0@finlytest.io')
#     @approved_report = @employee.reports.approved.first
#     @submitted_report = @employee.reports.processing.first
#   end
#
#   test "successful marking of a report as reimbursed after they're approved" do
#     reimburse_op = Report::MarkAsReimbursed.new(@finance, report: @approved_report)
#     assert_difference '@employee.reports.approved.count', -1 do
#       @report = reimburse_op.run
#     end
#
#   end
#
# end