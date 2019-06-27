class Procurements::Invoices::RecurringInvoices::Create < Procurements::Invoices::Base

  attr_accessor :payment_agreement_type_id, :payment_agreement, :general_invoice, :rental_invoice, :template, :document, :invoice, :payment_agreement_type, :procurement_id

  def init
    self.payment_agreement_type_id = params[:payment_agreement_type_id]
    self.payment_agreement_type = params[:payment_agreement_type]
    self.payment_agreement = user.company.payment_agreements.find_by_id params[:payment_agreement_id]
    self.procurement_id = params[:procurement_id]
  end

  def validate
    if payment_agreement.blank?
      add_message :error, "Agreement does not exist"
      return
    end
  end

  def process
    case payment_agreement_type
    when 'general_invoice'
      self.general_invoice = user.company.inward_invoices.find_by_id payment_agreement_type_id
      params[:template_id] = general_invoice.resource_template_id
      self.template = general_invoice.resource_template
    when 'rental_invoice'
      self.rental_invoice = user.company.inward_invoices.find_by_id payment_agreement_type_id
      params[:template_id] = rental_invoice.resource_template_id
      self.template = rental_invoice.resource_template
    end

    if general_invoice.present?
      invoice_created = apply_template(general_invoice)
    end

    if rental_invoice.present?
      invoice_created = apply_template(rental_invoice)
    end

    unless invoice_created
      add_message :error, 'Invoice is not created'
      procurement = user.company.procurements.find_by_id procurement_id
      procurement.destroy
      return
    end
  end


  def post_process
  end



  def apply_template(resource)
    case
    when resource.is_a?(Invoice)
    self.invoice = resource.amoeba_dup
    if self.invoice.save && self.invoice.update(created_by: user, procurement_id: procurement_id, invoice_type_id: InwardInvoiceType.id_for(:recurring_invoice))
      Trail.create(parent_type: 'Invoice', parent_id: self.invoice.id, action_user_id: user.id, action_id: TrailAction.id_for(:invoice_created))
      return true
    end
    end
  end
end