class Admin::Cards::AssignRequests::Accessable < Admin::Cards::AssignRequests::Base
  attr_accessor :card_assign_request, :workflow, :admin_user, :workflow_level

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
    # review_ids = workflow.levels.with_position(current_review_position).pluck(:admin_reviewer_id)
    # self.is_reviewer = review_ids.include? admin_user.id
    self.workflow_level = workflow.levels.with_position(current_review_position).with_admin_user(admin_user.id)&.first
  end

  def success
    params[:workflow_level] = self.workflow_level
    Admin::Cards::AssignRequests::Accessable::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::Accessable::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :workflow_level, :is_reviewer, :trigger_email

    def init
      self.workflow_level = params[:workflow_level]
      self.is_reviewer = !!self.workflow_level&.reviewer
      self.trigger_email = !!self.workflow_level&.trigger_email
    end

  end

end