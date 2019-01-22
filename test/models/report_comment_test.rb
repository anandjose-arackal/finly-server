# == Schema Information
#
# Table name: report_comments
#
#  id                       :integer          not null, primary key
#  report_id                :integer          not null
#  report_comment_action_id :integer          not null
#  user_id                  :integer
#  expense_id               :integer
#  updated_field            :string(255)
#  updated_from             :text(65535)
#  updated_to               :text(65535)
#  rejected_to_id           :integer
#  content                  :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  payment_id               :integer
#  delegated_action_user_id :integer
#

require 'test_helper'

class ReportCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #   when ReportCommentAction.report_update_id
  #   validate_attributes [:user_id, :updated_field, :updated_from, :updated_to]
  #   when ReportCommentAction.report_reimbursed_id
  #   validate_attributes [:user_id, :payment]
  #   when ReportCommentAction.report_attach_receipt_id
  #   when ReportCommentAction.report_detach_receipt_id
  #   when ReportCommentAction.expense_add_id
  #   validate_attributes [:user_id, :expense_id]
  #   when ReportCommentAction.expense_remove_id
  #   validate_attributes [:user_id, :expense_id]
  #   when ReportCommentAction.expense_reject_id
  #   validate_attributes [:user_id, :expense_id]
  #   when ReportCommentAction.expense_update_id
  #   validate_attributes [:user_id, :expense_id, :updated_field, :updated_from, :updated_to]
  # else

  def setup
    @report = Report.last
  end

  test 'base requirements' do
    # Report ID and Report Action ID is required for creating any comments
    u = User.first
    assert_not ReportComment.new(user: u, content: 'test').valid?
    assert_not ReportComment.new(report: @report, user: u, content: 'test').valid?
    assert_not ReportComment.new(user: u, report_comment_action_id: ReportCommentAction.report_comment_id, content: 'test').valid?
    assert ReportComment.new(user: u, content: 'test', report_comment_action_id: ReportCommentAction.report_comment_id, report: @report).valid?
  end

  test 'Commenting' do
    u = User.first

    # User ID and Content is required for adding a new comment
    assert_not ReportComment.new(content: 'test', report_comment_action_id: ReportCommentAction.report_comment_id, report: @report).valid?
    assert_not ReportComment.new(user: u, report_comment_action_id: ReportCommentAction.report_comment_id, report: @report).valid?
    assert ReportComment.new(user: u, content: 'test', report_comment_action_id: ReportCommentAction.report_comment_id, report: @report).valid?
  end

  test 'report approval flow' do
    u = User.first

    # User ID is required for approval flow
    assert_not ReportComment.new(report_comment_action_id: ReportCommentAction.report_retract_id, report: @report).valid?
    assert ReportComment.new(user: u, report_comment_action_id: ReportCommentAction.report_retract_id, report: @report).valid?
  end

  test 'update flow' do
    u = User.first

    # :user_id, :updated_field, :updated_from, :updated_to is required for update report comment
    assert_not ReportComment.new(report_comment_action_id: ReportCommentAction.report_update_id, report: @report).valid?
    assert_not ReportComment.new(user: u, report_comment_action_id: ReportCommentAction.report_update_id, report: @report).valid?
    assert_not ReportComment.new(user: u, updated_field: 'abc',
                                 report_comment_action_id: ReportCommentAction.report_update_id, report: @report).valid?
    assert_not ReportComment.new(user: u, updated_field: 'abc', updated_from: 'from',
                                 report_comment_action_id: ReportCommentAction.report_update_id, report: @report).valid?
    assert ReportComment.new(user: u, updated_field: 'abc', updated_from: 'from', updated_to: 'to',
                                 report_comment_action_id: ReportCommentAction.report_update_id, report: @report).valid?
  end

end
