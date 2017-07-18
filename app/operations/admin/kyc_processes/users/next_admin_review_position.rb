class Admin::KycProcesses::Users::NextAdminReviewPosition < Admin::KycProcesses::Users::Base
  attr_accessor :individual_kyc, :workflow, :next_review_position

  def pre_validate
    if params&.dig(:individual_kyc).blank?
      add_message :error, 'KYC Upgrade Request not found'
      return
    end
  end

  def init
    self.individual_kyc = params[:individual_kyc]
    self.workflow = individual_kyc&.admin_review_workflow
  end

  def validate
    if self.workflow.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end
  end

  def process
    current_review_position = individual_kyc.review_position
    self.next_review_position = (current_review_position + 1) if workflow.levels.with_position((current_review_position + 1)).present?
  end

  def success
    params[:next_review_position] = self.next_review_position
    Admin::KycProcesses::Users::NextAdminReviewPosition::Presenter.new(user, params, messages)
  end

  class Admin::KycProcesses::Users::NextAdminReviewPosition::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :next_review_position

    def init
      self.next_review_position = params[:next_review_position]
    end

    def is_final?
      self.next_review_position.nil?
    end

  end

end