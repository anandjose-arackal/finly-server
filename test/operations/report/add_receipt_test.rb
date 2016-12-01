# require 'test_helper'
# require 'helpers/report_operation_test_helper'
#
# class AddReceiptTest < ActiveSupport::TestCase
#   include ReportOperationTestHelper
#
#   def setup
#     @user = User.first
#     @other_user = User.second
#     @report = create_report(@user)
#     @other_report = create_report(@other_user)
#     @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
#     @receipt_params = {receipt: {image: @image},
#                        expense_id: @report.id}
#
#   end
#
#   test "should receipt to one's own report" do
#     receipt_op = Report::Receipts::Add.new(@user, { report_id: @report.id,
#                                                 receipt: {image: @image} })
#     assert_difference '@report.receipts.count', 1 do
#       @receipt = receipt_op.run
#     end
#     assert_equal @report.id, @receipt.parent_id
#   end
#
#   test "cannot receipt to someone else's report" do
#     receipt_op = Report::Receipts::Add.new(@user, { report_id: @other_report.id,
#                                                     receipt: {image: @image} })
#     assert_no_difference '@user.receipts.count' do
#       begin
#         @receipt = receipt_op.run
#       rescue
#         @rescued = true
#       end
#     end
#     assert @rescued
#     assert @other_report.receipts.empty?
#   end
#
#   test "Cannot add a receipt to a repor that's not open or retracted" do
#     # adding receipt to a processing report fails
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @report = @employee.reports.processing.first
#     receipt_op = Report::Receipts::Add.new(@employee, { report_id: @report.id,
#                                                     receipt: {image: @image} })
#     assert_no_difference '@report.receipts.count' do
#       @receipt = receipt_op.run
#     end
#     assert_not @receipt
#     assert @report.receipts.empty?
#
#     # adding receipt to an approved report should also fail
#     @report = @employee.reports.approved.first
#     receipt_op = Report::Receipts::Add.new(@employee, { report_id: @report.id,
#                                                     receipt: {image: @image} })
#     assert_no_difference '@report.receipts.count' do
#       @receipt = receipt_op.run
#     end
#     assert_not @receipt
#     assert @report.receipts.empty?
#   end
# end