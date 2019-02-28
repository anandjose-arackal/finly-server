# require 'test_helper'
# require 'helpers/report_operation_test_helper'
#
# class RetractTest < ActiveSupport::TestCase
#
#   include ReportOperationTestHelper
#
#   def setup
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @second_manager = User.find_by(email: 'manager1@finlytest.io')
#   end
#
#   test "Should be able to retract in processing state" do
#     @report = @employee.reports.processing.first
#     retract_op = Reports::Retract.new(@employee, report_id: @report.id)
#     assert_difference '@report.comments.count', 1 do
#       assert_difference 'ReportTrack.count', 1 do
#         @report = retract_op.run
#       end
#     end
#     assert_equal ReportStatus.retracted_id, @report.status_id
#   end
#
#   test "Cannot retract a report that's already approved or reimbursed" do
#     @report = @employee.reports.approved.first
#     retract_op = Reports::Retract.new(@employee, report_id: @report.id)
#     assert_no_difference '@report.comments.count' do
#       @result = retract_op.run
#     end
#     assert_not @result
#     assert_not retract_op.errors.empty?
#
#     # cannot retract reimbursed reports as well
#     @report.update_attributes(report_status_id: ReportStatus.reimbursed_id) # temporarily updating report to reimbursed state
#     retract_op = Reports::Retract.new(@employee, report_id: @report.id)
#     assert_no_difference '@report.comments.count' do
#       @result = retract_op.run
#     end
#     assert_not @result
#     assert_not retract_op.errors.empty?
#   end
# end