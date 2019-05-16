class PaymentAgreements::Show < PaymentAgreements::Base
  attr_accessor :payment_agreement, :policies, :reviewal_chains
  
  def init
    pa_id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by(id: pa_id)

  end

  def validate
    if self.payment_agreement.blank? || payment_agreement.company_id != user.company_id
      add_message :error, "Agreement not found for this user."
    end
    # Add role based validations
  end

  def process

  end

  def success
    params[:payment_agreement] = self.payment_agreement
    Procurements::PurchaseRequests::Show::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Show::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement, :reviewal_chain

    def init
      self.payment_agreement = params[:payment_agreement]
      self.reviewal_chain = payment_agreement.get_reviewal_chain if !payment_agreement.draft? && !payment_agreement.retracted? && !payment_agreement.rejected?
    end

  end
end