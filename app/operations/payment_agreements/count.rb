class PaymentAgreements::Count < PaymentAgreements::Base

  attr_accessor :statuses

  def init
    self.statuses ||= {}
  end

  def validate
  end

  def process
    result  = ::PaymentAgreements::Index.(user, params)
    if result.success?
      self.statuses = result.payment_agreements.joins(:status).group('payment_agreement_statuses.name').count
      self.statuses['all'] = statuses.values.sum rescue nil
      # Processing are those which are created by user and are in the approval flow
      self.statuses['processing'] = result.payment_agreements.where(status_id: PaymentAgreementStatus.id_for(:awaiting_approval), creator_id: user.id).count rescue 0
      awaiting_approval_ids = PaymentAgreement.awaiting_action_items(user.id).pluck(:id)
      self.statuses['awaiting_approval'] = result.payment_agreements.where(id: awaiting_approval_ids).count
    end
  end

  def success
    params[:statuses] = self.statuses
    PaymentAgreements::Count::CountPresenter.new(user, params, messages)
  end

  class PaymentAgreements::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :statuses

    def init
      self.statuses = params[:statuses]
    end

  end

end