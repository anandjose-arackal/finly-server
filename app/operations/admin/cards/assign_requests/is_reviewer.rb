class Admin::Cards::AssignRequests::IsReviewer < Admin::Cards::AssignRequests::Base
  attr_accessor :card_assign_request, :workflow, :admin_user, :is_reviewer

  def pre_validate
    if params&.dig(:admin_user).blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:card_assign_request).blank?
      add_message :error, 'Card Assign Request not found'
      return
    end
  end

  def init
    self.admin_user = params[:admin_user]
    self.card_assign_request = params[:card_assign_request]
    self.workflow = self.card_assign_request&.admin_review_workflow
  end

  def validate
    if self.workflow.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end
  end

  def process
    current_review_position = self.card_assign_request.review_position
    review_ids = workflow.levels.with_position(current_review_position).pluck(:admin_reviewer_id)
    self.is_reviewer = review_ids.include? admin_user.id
  end

  def success
    params[:is_reviewer] = self.is_reviewer
    Admin::Cards::AssignRequests::NextAdminReviewPosition::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::NextAdminReviewPosition::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :is_reviewer

    def init
      self.is_reviewer = params[:is_reviewer]
    end

  end

end