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
    self.workflow = card_assign_request&.admin_review_workflow
  end

  def validate
    if self.workflow.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end
  end

  def process
    current_review_position = card_assign_request.review_position
    individual_kyc = card_assign_request.card_owner.individual_kyc
    if [KycStatus.id_for(:submitted), KycStatus.id_for(:retracted), KycStatus.id_for(:processing), KycStatus.id_for(:approved), KycStatus.id_for(:completed)].include? individual_kyc.kyc_status_id
      self.next_review_position = (current_review_position + 1) if workflow.levels.with_position((current_review_position + 1)).present?
    else
      self.next_review_position = nil
    end
  end

  def success
    params[:next_review_position] = self.next_review_position
    Admin::Cards::AssignRequests::NextAdminReviewPosition::Presenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::NextAdminReviewPosition::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :next_review_position

    def init
      self.next_review_position = params[:next_review_position]
    end

    def is_final?
      self.next_review_position.nil?
    end

  end

end