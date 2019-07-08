class Procurements::Invoices::RecurringInvoices::Create < Procurements::Invoices::Base

  attr_accessor :payment_agreement_type_id, :payment_agreement, :general_invoice, :rental_invoice, :document, :payment_agreement_type, :procurement_id, :previous_upcoming_invoice

  def init
    self.payment_agreement_type_id = params[:payment_agreement_type_id]
    self.payment_agreement_type = params[:payment_agreement_type]
    self.payment_agreement = user.company.payment_agreements.find_by_id params[:payment_agreement_id]
    self.procurement_id = params[:procurement_id]
  end

  def validate
    if procurement_id.blank?
      add_message :error, 'Procurement not found'
      return
    end
    if payment_agreement.blank?
      add_message :error, "Agreement does not exist"
      return
    end
  end

  def process
    case payment_agreement_type
    when 'general_invoice'
      self.general_invoice = user.company.inward_invoices.find_by_id payment_agreement_type_id
    when 'rental_invoice'
      self.rental_invoice = user.company.inward_invoices.find_by_id payment_agreement_type_id
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
    # Resource can be general_invoice or rental_invoice
    case
    when resource.is_a?(Invoice)
      binding.pry
    new_invoice = resource.amoeba_dup
    new_invoice.invoice_id = nil
    if new_invoice.save

      
      # Temporary fix for demo as it started happening now. Somehow amoeba is showing correct no. of objects but on saving doubles the no. of records
      items = new_invoice.items.group(:description).having('count("description") > 1').count(:description)
      items.each do |key, value|
        duplicates = new_invoice.items.where(description: key)[1..value-1]
        duplicates.each(&:destroy)
      end

      ######## Temp fix for demo only ########


      update_invoice_attributes(resource, new_invoice, {invoice_type: 'recurring_invoice', update_procurement: true})
      # Create trail for general/rental_invoice that recurring invoice has been created
      trail_options = {action: 'invoice_created', parent: resource, parent_type: 'Invoice'}
      create_trail(trail_options)
      create_next_upcoming_invoice(resource)
      # Since recurring invoice has been created and next upcoming invoice has been created, previous invoice will not be upcoming_invoice anymore
      set_upcoming_invoice_status(resource, false)
      return true
    end
    end
  end


  def create_next_upcoming_invoice(previous_upcoming_invoice)
    if next_upcoming_invoice_required(previous_upcoming_invoice)
      next_upcoming_invoice = previous_upcoming_invoice.amoeba_dup
      optional_params = {invoice_type: previous_upcoming_invoice.invoice_type.name}
      # Create trail to log that next upcoming invoice has been created against the previous general/rental_invoice
      trail_options = {action: 'upcoming_invoice_created', parent: previous_upcoming_invoice, parent_type: 'Invoice'}
      next_upcoming_invoice.invoice_id = nil
      if next_upcoming_invoice.save
        update_invoice_attributes(previous_upcoming_invoice, next_upcoming_invoice, optional_params)
        upcoming_date = invoice_upcoming_date(previous_upcoming_invoice)
        if upcoming_date.blank?
          add_message :error, 'Cannot set upcoming date'
          return
        end
        set_upcoming_invoice_status(next_upcoming_invoice, true)
        set_payment_agreement_upcoming_invoice_date(next_upcoming_invoice, upcoming_date)
        set_payment_agreement_upcoming_invoice_due_date(previous_upcoming_invoice, next_upcoming_invoice)
        create_trail(trail_options)
      end
    end
  end


  # Some attributes are set here, some are nullified in model as per logic used in other places, hence updating explicitly 
  def update_invoice_attributes(original_invoice, new_invoice, options={})
    new_invoice.update(created_by: user, invoice_type_id: InwardInvoiceType.id_for(options[:invoice_type].to_sym), due_date: original_invoice.due_date)
    new_invoice.update(procurement_id: procurement_id) if options[:update_procurement]
  end


  #TODO - On invoice deletion, reset the upcoming invoice agreement based due date  

  # def set_next_due_date_for_upcoming_invoice(trail, resource)
  #   # 'Resource' here means agreement based invoice i.e. general or rental
  #   agreement_expiration_date = payment_agreement.expiration_date.to_date
  #   if (agreement_expiration_date.present? && (agreement_expiration_date >= Date.today) || payment_agreement.no_expiration)
  #     case
  #     when invoice.billing_type_id == BillingType.id_for(:fixed_periodic)
  #       last_invoice_created_at = trail.created_at.to_date
  #       number = resource.invoice_frequency&.number
  #       period_id = resource.invoice_frequency&.period_id
  #       billing_start_date = resource.billing_start_date&.to_date
  #       if number.present?
  #         case
  #         when period_id == Period.id_for(:month)
  #           next_invoice_due_date = last_invoice_created_at + number.to_i.month
  #           resource.update(payment_agreement_upcoming_date: next_invoice_due_date)
  #         end
  #       end
  #     # when invoice.billing_type_id == BillingType.id_for(:one_time)
  #     #   resource.update(payment_agreement_upcoming_date: resource&.execution_date&.to_date)
  #     end
  #   end
  # end

  def create_trail(options={})
    Trail.create(parent_type: options[:parent_type], parent_id: options[:parent].id, action_user_id: user.id, action_id: TrailAction.id_for(options[:action].to_sym))
  end

  def set_payment_agreement_upcoming_invoice_date(upcoming_invoice, upcoming_date)
    set_upcoming_invoice_status(upcoming_invoice, true)
    upcoming_invoice.update(payment_agreement_upcoming_date: upcoming_date)
  end

  def set_payment_agreement_upcoming_invoice_due_date(previous_invoice, next_invoice)
    due_date = calculate_due_date(previous_invoice)
    next_invoice.update(due_date: due_date)
  end

  # Sets true if payment agreement invoice is upcoming.
  # Set false if actual recurring invoice has been created against payment agreement invoice 
  def set_upcoming_invoice_status(invoice, boolean_status)
    invoice.update(is_payment_agreement_upcoming_invoice: boolean_status)
  end


  # Return next upcoming date w.r.t the previous invoice and that will be previous invoice upcoming date + invoice frequency
  def invoice_upcoming_date(previous_invoice)
    agreement_expiration_date = payment_agreement.expiration_date&.to_date
    if (agreement_expiration_date.present? && agreement_expiration_date >= Date.today) || payment_agreement.no_expiration
      case
      when previous_invoice.billing_type_id == BillingType.id_for(:fixed_periodic)
        number = previous_invoice.invoice_frequency&.number
        period_id = previous_invoice.invoice_frequency&.period_id
        if number.present?
          case
          when period_id == Period.id_for(:month)
            next_invoice_due_date = previous_invoice.payment_agreement_upcoming_date + number.to_i.month
            return next_invoice_due_date
          end
        end
      # when invoice.billing_type_id == BillingType.id_for(:one_time)
      #   resource.update(payment_agreement_upcoming_date: resource&.execution_date&.to_date)
      end
    end
    nil
  end


  # Calculation of due date will be on the basis of previous due date and payment_term
  # due_date = previous_due_date + no_of_day_in_payment_term
  def calculate_due_date(invoice=nil)
    due_date = invoice.payment_agreement_upcoming_date + invoice.payment_term.days_after.to_i
  end

  def next_upcoming_invoice_required(previous_upcoming_invoice)
    previous_upcoming_invoice.billing_type_id == BillingType.id_for(:fixed_periodic) && (self.payment_agreement.no_expiration || invoice_upcoming_date(previous_upcoming_invoice))
  end

end