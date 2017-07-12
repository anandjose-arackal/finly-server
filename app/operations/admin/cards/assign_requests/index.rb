class Admin::Cards::AssignRequests::Index < Admin::Cards::AssignRequests::Base
  attr_accessor :assign_card_requests, :workflow, :reviewer_level

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.workflow = AdminReviewWorkflow.workflow_for :assign_card
    self.reviewer_level = workflow.levels.with_admin_reviewer(user.id)&.first
    if self.workflow.present? and self.reviewer_level.present?
      self.assign_card_requests = CardAssignRequest.with_admin_review_workflow(self.workflow.id).with_review_position(reviewer_level.position)
    end
  end

  def validate

  end

  def success
    params[:assign_card_requests] = self.assign_card_requests
    Admin::Cards::AssignRequests::Index::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :assign_card_requests

    def init
      self.assign_card_requests = params[:assign_card_requests]
    end

    def actions

    end

  end

end