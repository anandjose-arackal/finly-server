class PaymentAgreements::Create < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params

  def init
    self.payment_agreement_params = payment_agreement_parameters
  end

  def validate
    # unless user.is_payment_agreement_initiator?
    #   add_message :error, 'You do not have permission for this action'
    #   return
    # end
  end

  def process
    self.payment_agreement = user.company.payment_agreements.build(payment_agreement_params)
    # self.payment_agreement = PaymentAgreement.new(payment_agreement_params)
    self.payment_agreement.status_id = PaymentAgreementStatus.id_for(:draft)
    self.payment_agreement.creator_id = user.id
    # self.payment_agreement.company_id = user.company_id
    if self.payment_agreement.save && self.payment_agreement.reload
      update_amount_attributes
      set_due_date_for_general_invoice
      set_due_date_for_rental_invoice
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

  # Need to make it close to invoice
  # All amount attrbutes are not being updated using InvoiceUtil
  # Will check it

  def update_amount_attributes
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.each do |general_invoice|
        general_invoice.update_taxable_and_orig_amount_value
        general_invoice.items.map(&:update_taxable_amount_value)
        # InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, nil, general_invoice)
        # general_invoice.save!
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, general_invoice)
        general_invoice.save!
        if general_invoice.tds_slab_id.present?
          apply_tds_on_amount(general_invoice)
        end
      end
    end

    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.each do |rental_invoice|
        rental_invoice.update_taxable_and_orig_amount_value
        rental_invoice.items.map(&:update_taxable_amount_value)
        # InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, nil, rental_invoice)
        # rental_invoice.save!
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, rental_invoice)
        rental_invoice.save!
        if rental_invoice.tds_slab_id.present?
          apply_tds_on_amount(rental_invoice)
        end
      end
    end

    # if payment_agreement.general_invoices.present?
    #   payment_agreement.general_invoices.map{|i| i.items.map(&:update_taxable_amount_value)}
    #   payment_agreement.general_invoices.map{|i| i.items.map(&:update_net_amount_value)}
    #   payment_agreement.general_invoices.map{|i| i.items.map(&:update_tax_amount_value)}
    #   payment_agreement.general_invoices.map(&:update_net_amount_value)
    # end

    # if payment_agreement.rental_invoices.present?
    #   payment_agreement.rental_invoices.map{|i| i.items.map(&:update_taxable_amount_value)}
    #   payment_agreement.rental_invoices.map{|i| i.items.map(&:update_net_amount_value)}
    #   payment_agreement.rental_invoices.map{|i| i.items.map(&:update_tax_amount_value)}
    #   payment_agreement.rental_invoices.map(&:update_net_amount_value)
    # end

    # if payment_agreement.beneficiary_payments.present?
    #   payment_agreement.beneficiary_payments
    # end

    # if payment_agreement.security_deposits.present?
    #   payment_agreement.security_deposits
    # end
  end


  def set_due_date_for_general_invoice
    self.payment_agreement.general_invoices.map do |general_invoice|
      number = general_invoice.invoice_frequency&.number
      period_id = general_invoice.invoice_frequency&.period_id
      billing_start_date = general_invoice.billing_start_date&.to_date
      # Set rules for calculation of payment date based on period set
      case 
      when period_id == Period.id_for(:month)
        due_date = billing_date
        general_invoice.update(agreement_based_next_due_date: due_date) if due_date.present?
      end
    end
  end

  def set_due_date_for_rental_invoice
    self.payment_agreement.rental_invoices.map do |rental_invoice|
      number = rental_invoice.invoice_frequency&.number
      period_id = rental_invoice.invoice_frequency&.period_id
      billing_start_date = rental_invoice.billing_start_date&.to_date
      # Set rules for calculation of payment date based on period set
      case 
      when period_id == Period.id_for(:month)
        due_date = billing_start_date
        rental_invoice.update(agreement_based_next_due_date: due_date) if due_date.present?
      end
    end
  end

  def apply_tds_on_amount(invoice)
    if invoice.tds_slab_id.present?
      tds_percentage = invoice&.tds_slab&.tds.to_f
      # Substract tds from sum of net amount of items
      item_net_amount_sum = invoice.items.joins(:net_amount).pluck('amounts.value').sum
      net_amt = item_net_amount_sum - (item_net_amount_sum*tds_percentage/100)
      if invoice.net_amount.present?
        invoice.net_amount.update(value: net_amt)
      else
        invoice.create_net_amount(value: net_amt, currency_id: 1)
      end
    end
  end

end