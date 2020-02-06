class PaymentAgreements::Show < PaymentAgreements::Base
  attr_accessor :payment_agreement, :policies, :reviewal_chains, :general_invoices, :rental_invoices, :security_deposits, :beneficiary_payments
  
  def init
    pa_id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by(id: pa_id)

  end

  def validate
    if self.payment_agreement.blank? || payment_agreement.company_id != user.company_id
      add_message :error, "Agreement not found for this user."
      return
    end
    # Add role based validations
    validate_document_access
  end

  def process
    self.general_invoices = self.payment_agreement.general_invoices.template_invoices
    self.rental_invoices = self.payment_agreement.rental_invoices.template_invoices
    self.security_deposits = self.payment_agreement.security_deposits
    self.beneficiary_payments = self.payment_agreement.beneficiary_payments
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    params[:security_deposits] = self.security_deposits
    params[:beneficiary_payments] = self.beneficiary_payments
    Procurements::PurchaseRequests::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement, :reviewal_chain, :general_invoices, :rental_invoices, :security_deposits, :beneficiary_payments

    def init
      self.payment_agreement = params[:payment_agreement]
      self.general_invoices = params[:general_invoices]
      self.rental_invoices = params[:rental_invoices]
      self.security_deposits  = params[:security_deposits]
      self.beneficiary_payments = params[:beneficiary_payments]
      self.reviewal_chain = payment_agreement.get_reviewal_chain if !payment_agreement.draft? && !payment_agreement.retracted? && !payment_agreement.rejected?

    end

  end

  private
  def validate_document_access
    return if payment_agreement.validate_if_owner(user)
    return if payment_agreement.validate_if_admin(user) && (!payment_agreement.draft? || (payment_agreement.creator_id == user.id) || payment_agreement.creator_id.blank?)

    return if payment_agreement.validate_if_reviewer(user)
    return if payment_agreement.validate_if_auditor(user)
    return if user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor?
    return if user.is_bank_payment_request_initiator?
    raise_unauthorized_exception
  end
end