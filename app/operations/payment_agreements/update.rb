class PaymentAgreements::Update < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params, :document_reviewer_mappings_params, :custom_fields

  def init
    super
    self.payment_agreement_params = payment_agreement_parameters
    self.payment_agreement = user.company.payment_agreements.find_by_id(params[:id])
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:invoice, :custom_fields)
  end

  def validate
    self.payment_agreement.assign_attributes(payment_agreement_parameters)
    validate_invoice_frequency
    validate_invoice_start_end_date
    check_agreement_item_presence
    validate_start_end_date_consecutiveness
    billing_type_validations
    validate_agreement_item_combinations
  end

  def process
    clear_expiration_date_on_no_expiration
    create_or_update_custom_fields
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.map{ |general_invoice| general_invoice.set_creator_and_company(user)}
    end
    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.map{ |rental_invoice| rental_invoice.set_creator_and_company(user)}
    end
    if payment_agreement.valid?
      # Set validation of DLRMs
      if PaymentAgreement.status_ids(:open, :retracted, :rejected).include?(payment_agreement.status_id) && payment_agreement.creator_id == user.id

        dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::ValidationUpdate.(user, {
          reviewal_document: self.payment_agreement,
          document_reviewer_mappings_params: document_reviewer_mappings_params
        })

        unless dlrm_validation_op.success?
          add_message :error, dlrm_validation_op.messages[:error]
          return
        end
      end
    end


    if self.payment_agreement.save && self.payment_agreement.reload
      update_item_attributes
      # set_due_date_for_general_invoices if payment_agreement.general_invoices.present?
      # set_due_date_for_rental_invoices if payment_agreement.rental_invoices.present?
      # set_due_date_for_beneficiary_payments if payment_agreement.beneficiary_payments.present?
      # set_due_date_for_security_deposits if payment_agreement.security_deposits.present?
      # update_line_item_attributes if payment_agreement.general_invoices.present? || payment_agreement.rental_invoices.present?

      # Set total amount on agreement level
      update_total_amount
      params[:reviewal_document] = self.payment_agreement
      params[:document_reviewer_mappings] = document_reviewer_mappings_params
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
      end
      return
    else
      add_message :error, payment_agreement.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Successfully updated agreements'
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::Update::UpdatePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Update::UpdatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
    end
  end


end