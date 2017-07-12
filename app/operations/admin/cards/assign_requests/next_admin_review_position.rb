class Admin::Cards::AssignRequests::NextAdminReviewPosition < Admin::Cards::AssignRequests::Base
  attr_accessor :card_assign_request, :workflow, :next_review_position

  def pre_validate
    if params&.dig(:card_assign_request).blank?
      add_message :error, 'Card Assign Request not found'
      return
    end
  end

  def init
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
    self.next_review_position = (current_review_position + 1) if workflow.levels.with_position((current_review_position + 1)).present?
  end

  def success
    params[:next_review_position] = self.next_review_position
    Admin::Cards::AssignRequests::NextAdminReviewPosition::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::NextAdminReviewPosition::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :next_review_position

    def init
      self.next_review_position = params[:next_review_position]
    end

    def is_final?
      self.next_review_position.nil?
    end

  end

end