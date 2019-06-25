class Procurements::Invoices::RecurringInvoices::Create < Procurements::Invoices::Base

  attr_accessor :beneficiary_payment, :payment_agreement_type_id, :payment_agreement, :beneficiary_payment, :general_invoice, :rental_invoice, :template, :document, :invoice

  def init
    payment_agreement_type_id = params[:payment_agreement_type_id]
    payment_agreement_type = params[:payment_agreement_type]
    self.payment_agreement = user.company.payment_agreements.find_by_id params[:payment_agreement_id]
  end

  def validate
    if payment_agreement.blank?
      add_message :error, "Agreement does not exist"
      return
    end
    case payment_agreement_type
    when 'beneficiary'
      self.beneficiary_payment = user.company.beneficiary_payments.find_by_id payment_agreement_type_id
      params[:template_id] = beneficiary_payment.resource_template_id
      self.template = beneficiary_payment.resource_template
    when 'general_invoice'
      self.general_invoice = user.company.general_invoices.find_by_id payment_agreement_type_id
      params[:template_id] = general_invoice.resource_template_id
      self.template = general_invoice.resource_template
    when 'rental_invoice'
      self.rental_invoice = user.company.rental_invoices.find_by_id payment_agreement_type_id
      params[:template_id] = rental_invoice.resource_template_id
      self.template = rental_invoice.resource_template
    end
  end

  def process
    if beneficiary_payment.present?
      # user.company.inward_invoices.create(beneficiary_to_invoice_params)
      apply_template(beneficiary_payment)
    end

    if general_invoice.present?
      # user.company.inward_invoices.create(general_invoice_to_invoice_params)
      apply_template(general_invoice)
    end

    if rental_invoice.present?
      # user.company.inward_invoices.create(rental_invoice_to_invoice_params)
      apply_template(rental_invoice)
    end
  end


  def post_process
  end

  def apply_template(resource)
    result = Template::Apply.(user, template: self.template, resource: resource)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.invoice = result.resource
    self.invoice.update(created_by: user)
  end



end