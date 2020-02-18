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
    self.payment_agreement = user.company.payment_agreements.build(payment_agreement_params)
    self.payment_agreement.status_id = PaymentAgreementStatus.id_for(:draft)
    self.payment_agreement.creator_id = user.id
    self.payment_agreement.company_id = user.company_id
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.each do |general_invoice| 
        general_invoice.set_creator_and_company(user)
        update_invoice_limit(general_invoice)
      end
    end
    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.each do |rental_invoice| 
        rental_invoice.set_creator_and_company(user)
      end
    end
    validate_item_quantity
    ActiveRecord::Base.transaction do
      if self.payment_agreement.save
        # checks to see if items are there or not
        # checks to see if general_invoice or rental_invoice have same items
        validate_invoice_line_items unless has_errors?

        # For fixed periodic, prepaid yes/no should be same of all invoices
        validate_prepaid_consistency unless has_errors?

        # checks to see if atleast one security deposit but not more, is there for all vendors
        security_deposit_validation unless has_errors?

        # Invoice frequency should be same for all agreement items. E.g. If agreement has four rentals under fixed periodic, all rental should have same invoice frequency
        validate_invoice_frequency unless has_errors?


        validate_invoice_start_end_date unless has_errors?
        fixed_periodic_grouped_vendor_validations unless has_errors?
        check_agreement_item_presence unless has_errors?
        # validate_start_end_date_consecutiveness unless has_errors?
        billing_type_validations unless has_errors?
        validate_agreement_item_combinations unless has_errors?
        create_or_update_custom_fields
      end
      if has_errors?
        raise ActiveRecord::Rollback
        return
      end
    end
  end

  def process
    clear_expiration_date_on_no_expiration
    return if has_errors?
    if self.payment_agreement.save && self.payment_agreement.reload
      update_item_attributes

      # Set total amount on agreement level
      update_total_amount

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

  def set_custom_field
    self.payment_agreement.invoices {|invoice| custom_field_setup(invoice) }
  end

  # def custom_field_setup(invoice)
  #   CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), reset_fields: true, save: true)
  # end

end