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
    if self.invoice.save && self.invoice.update(created_by: user, procurement_id: procurement_id, invoice_type_id: InwardInvoiceType.id_for(:recurring_invoice), date: resource&.agreement_based_next_due_date&.to_date)
      trail = Trail.create(parent_type: 'Invoice', parent_id: resource.id, action_user_id: user.id, action_id: TrailAction.id_for(:invoice_created))
      set_next_due_date_for_upcoming_invoice(trail, resource)
      return true
    end
    end
  end

  #TODO - On invoice deletion, reset the upcoming invoice agreement based due date  

  def set_next_due_date_for_upcoming_invoice(trail, resource)
    # 'Resource' here means agreement based invoice i.e. general or rental
    agreement_expiration_date = payment_agreement.expiration_date.to_date
    if (agreement_expiration_date.present? && (agreement_expiration_date >= Date.today) || payment_agreement.no_expiration)
      case
      when invoice.billing_type_id == BillingType.id_for(:fixed_periodic)
        last_invoice_created_at = trail.created_at.to_date
        number = resource.invoice_frequency&.number
        period_id = resource.invoice_frequency&.period_id
        billing_start_date = resource.billing_start_date&.to_date
        if number.present?
          case
          when period_id == Period.id_for(:month)
            next_invoice_due_date = last_invoice_created_at + number.to_i.month
            resource.update(agreement_based_next_due_date: next_invoice_due_date)
          end
        end
      when invoice.billing_type_id == BillingType.id_for(:one_time)
        resource.update(agreement_based_next_due_date: resource&.execution_date&.to_date)
      end
    end
  end
end