class PaymentAgreements::Create < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params

  def init
    self.payment_agreement_params = payment_agreement_parameters
  end

  def validate
    unless user.is_payment_agreement_initiator? || user.vendor_payment_admin?
      add_message :error, 'You do not have permission for this action'
      return
    end
    # check_agreement_item_presence
  end

  def process
    self.payment_agreement = user.company.payment_agreements.build(payment_agreement_params)
    # self.payment_agreement = PaymentAgreement.new(payment_agreement_params)
    return unless check_agreement_item_presence
    self.payment_agreement.status_id = PaymentAgreementStatus.id_for(:draft)
    self.payment_agreement.creator_id = user.id
    # self.payment_agreement.company_id = user.company_id
    if self.payment_agreement.save && self.payment_agreement.reload
      update_amount_attributes
      set_due_date_for_general_invoices if payment_agreement.general_invoices.present?
      set_due_date_for_rental_invoices if payment_agreement.rental_invoices.present?
      set_due_date_for_beneficiary_payments if payment_agreement.beneficiary_payments.present?
      set_due_date_for_security_deposits if payment_agreement.security_deposits.present?

      # Set total amount on agreement level
      update_total_amount

      # duplicate general/rental invoice department, cost_center in line items
      update_line_item_attributes if payment_agreement.general_invoices.present? || payment_agreement.rental_invoices.present?
      abp_attachment_ids = get_attachment_ids(params)
      Attachment.update_resource({ids: abp_attachment_ids, resource_id: self.payment_agreement.id, user: user}) if abp_attachment_ids.present?

      # self.payment_agreement.status_id = PaymentAgreementStatus.id_for(:draft)
      # self.payment_agreement.creator_id = user.id
      # Create document level reviewer mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.payment_agreement.reload
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        self.payment_agreement.destroy
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end
    else
      add_message :error, payment_agreement.errors.full_messages
    end

  end

  def post_process
    unless has_errors?
      add_message :success, 'Successfully created agreement'
    end
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::Create::CreatePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
    end

  end

  private
  def get_attachment_ids(params)
    if params.dig(:payment_agreement, :attachments_attributes).present?
      attachment_ids = []
      params.dig(:payment_agreement, :attachments_attributes).each{ |ele| attachment_ids << ele[:id] }
      return attachment_ids
    end
  end

  def check_agreement_item_presence
    if payment_agreement.general_invoices.blank? && payment_agreement.rental_invoices.blank? && payment_agreement.security_deposits.blank? && payment_agreement.beneficiary_payments.blank?
      add_message :error, 'Please add agreement item'
      return false
    end
    true
  end

end