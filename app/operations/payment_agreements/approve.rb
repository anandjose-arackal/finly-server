class PaymentAgreements::Approve < PaymentAgreements::Base

  attr_accessor :payment_agreement

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
    end
  end

  def process
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'approve'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    agreement_related_operations
    add_message :success, "You've approved the agreement"
  end

  def agreement_related_operations
    if self.payment_agreement.approved?
      update_one_time_invoice
      if self.payment_agreement.general_invoices.fixed_periodic_type.present?
        vendor_ids = self.payment_agreement.general_invoices.pluck(:vendor_id).uniq
        vendor_ids.each do |vendor_id|
          # create_upcoming_invoice(vendor_id, 'general_invoice')
          create_first_invoice(vendor_id, 'general_invoice')
        end
      end

      if self.payment_agreement.rental_invoices.fixed_periodic_type.present?
        vendor_ids = self.payment_agreement.rental_invoices.pluck(:vendor_id).uniq
        vendor_ids.each do |vendor_id|
          # create_upcoming_invoice(vendor_id, 'rental_invoice')
          create_first_invoice(vendor_id, 'rental_invoice')
        end
      end
    end
  end

  # After approval, first upcoming invoice is created
  # def create_upcoming_invoice(vendor_id, invoice_type)
  #   execution_date = self.payment_agreement.execution_date.to_date
  #   if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id, start_date: execution_date).present?
  #     self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id, start_date: execution_date).order(:start_date).each_with_index do |agreement_invoice, index|
  #       if index.zero?
  #         create_first_invoice(agreement_invoice)
  #       end
  #     end
  #   end
  # end

  def create_first_invoice(vendor_id, invoice_type)
    execution_date = self.payment_agreement.execution_date.to_date
    if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).present?
      invoice = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).order(:start_date).first
      frequency_based_end_date = (invoice.start_date&.to_date + invoice.invoice_frequency.number.month - 1.month).end_of_month
      self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).where("start_date <= ?", frequency_based_end_date.to_date).each do |reference_invoice|
        params[:vendor_id] = reference_invoice.vendor_id
        params[:first_reference_invoice] = reference_invoice
        params[:first_reference_invoice_type] = reference_invoice.class.name.underscore
        params[:first_start_date] = invoice&.start_date&.to_date
        upcoming_invoice_op = ::PaymentAgreements::CreateUpcomingInvoice.(user, params)
        unless upcoming_invoice_op.success?
          add_message :error, "Error occurred, first upcoming invoice is not created"
          return
        end
      end
    end
  end

  def update_one_time_invoice
    if self.payment_agreement.general_invoices.one_time_type.present?
      self.payment_agreement.general_invoices.one_time_type.update_all(is_payment_agreement_upcoming_invoice: true)
    end

    if self.payment_agreement.rental_invoices.one_time_type.present?
      self.payment_agreement.rental_invoices.one_time_type.update_all(is_payment_agreement_upcoming_invoice: true)
    end
  end



end