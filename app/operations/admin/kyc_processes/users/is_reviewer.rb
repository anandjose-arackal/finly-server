class Admin::KycProcesses::Users::IsReviewer < Admin::KycProcesses::Users::Base
  attr_accessor :individual_kyc, :workflow, :admin_user, :is_reviewer

  def pre_validate
    if params&.dig(:admin_user).blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:individual_kyc).blank?
      add_message :error, 'KYC Upgrade Request not found'
      return
    end
  end

  def init
    self.admin_user = params[:admin_user]
    self.individual_kyc = params[:individual_kyc]
    self.workflow = self.individual_kyc&.admin_review_workflow
  end

  def validate
    if self.workflow.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end
  end

  def process
    current_review_position = self.individual_kyc.review_position
    review_ids = workflow.levels.with_position(current_review_position).pluck(:admin_user_id)
    self.is_reviewer = review_ids.include? admin_user.id
  end

  def success
    params[:is_reviewer] = self.is_reviewer
    Admin::KycProcesses::Users::IsReviewer::SuccessPresenter.new(user, params, messages)
  end

  class Admin::KycProcesses::Users::IsReviewer::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :is_reviewer

    def init
      self.is_reviewer = params[:is_reviewer]
    end

  end

end