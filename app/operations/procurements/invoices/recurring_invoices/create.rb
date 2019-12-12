class Procurements::Invoices::RecurringInvoices::Create < Procurements::Invoices::Base

  attr_accessor :payment_agreement_type_id, :payment_agreement, :general_invoice, :rental_invoice, :document, :payment_agreement_type, :procurement_id, :previous_upcoming_invoice, :vendor

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

    if payment_agreement.status.terminated?
      add_message :error, "Unable to create invoice as agreement has been terminated"
      return
    end
  end

  def process
    case payment_agreement_type
    when 'general_invoice'
      self.general_invoice = user.company.general_invoices.find_by_id payment_agreement_type_id
    when 'rental_invoice'
      self.rental_invoice = user.company.rental_invoices.find_by_id payment_agreement_type_id
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

    case resource.class.name
    when 'GeneralInvoice'
      new_invoice = apply_general_invoice_template(resource)
      trail_action = 'general_invoice_created'
    when 'RentalInvoice'
      new_invoice = apply_rental_invoice_template(resource)
      trail_action = 'rental_invoice_created'
    end

    if resource.billing_type.fixed_periodic? || resource.billing_type.one_time?
      set_upcoming_invoice_status(resource, false)
    end

    update_invoice_attributes(resource, new_invoice, {invoice_type: 'recurring_invoice', update_procurement: true})

    #   # Create trail for general/rental_invoice that recurring invoice has been created
    trail_options = {action: trail_action, parent: resource, parent_type: resource.class.name}
    create_trail(trail_options)
    # Automatically create next upcoming invoice via scheduler too
    if resource.billing_type.fixed_periodic?
      # create_next_upcoming_invoice(resource)
    end
    
    # Invoice with billing type one time has actual invoice only once
    # Invoice with billing type fixed periodic has actual invoice only once per agreement invoice.
    if resource.billing_type.fixed_periodic? || resource.billing_type.one_time?
      set_upcoming_invoice_status(resource, false)
    end
    return true
    # end
    # end
  end


  def apply_general_invoice_template(general_invoice)
    validate_vendor(general_invoice)
    invoice = Invoice.new
    invoice.invoice_status_id = InwardInvoiceStatus.id_for(:open)
    invoice.agreement_item_type = "GeneralInvoice"
    invoice.agreement_item_id = general_invoice.id
    GeneralInvoice::TEMPLATE_COLUMNS.each do |column_name|
      invoice.send("#{column_name}=", general_invoice.send(column_name.to_sym))
    end
    GeneralInvoice::CLONE_RECORDS.each do |column_name|
      invoice.send("#{column_name}=", general_invoice.send(column_name.to_sym).dup)
    end
    update_due_date(invoice, general_invoice)
    if invoice.save 
      unless map_line_items(general_invoice, invoice)
        invoice.destroy
        add_message :error, "Unable to create general invoice"
        return
      end
      attach_agreement_item(invoice, 'general_invoice')
    end
    return invoice
  end

  def apply_rental_invoice_template(rental_invoice)
    validate_vendor(rental_invoice)
    invoice = Invoice.new
    invoice.invoice_status_id = InwardInvoiceStatus.id_for(:open)
    invoice.agreement_item_type = "RentalInvoice"
    invoice.agreement_item_id = rental_invoice.id
    RentalInvoice::TEMPLATE_COLUMNS.each do |column_name|
      invoice.send("#{column_name}=", rental_invoice.send(column_name.to_sym))
    end
    RentalInvoice::CLONE_RECORDS.each do |column_name|
      invoice.send("#{column_name}=", rental_invoice.send(column_name.to_sym).dup)
    end
    update_due_date(invoice, rental_invoice)
    if invoice.save
      unless map_line_items(rental_invoice, invoice)
        invoice.destroy
        add_message :error, "Unable to create rental invoice"
        return
      end
    end
    attach_agreement_item(invoice, 'rental_invoice')
    return invoice
  end

  def map_line_items(agreement_invoice, new_invoice)
    agreement_invoice.invoice_items.each do |item|
      new_line_item = new_invoice.items.new
      InvoiceLineItem::TEMPLATE_COLUMNS.each do |column_name|
        new_line_item.send("#{column_name}=", item.send(column_name.to_sym))
      end
      InvoiceLineItem::CLONE_RECORDS.each do |column_name|
        new_line_item.send("#{column_name}=", item.send(column_name.to_sym).dup)
      end
      new_line_item.parent_type = 'Invoice'
    end
    return new_invoice.save
  end

  def create_next_upcoming_invoice(agreement_invoice)
    setup_params(agreement_invoice)
    op = PaymentAgreements::CreateUpcomingInvoice.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      op.new_upcoming_invoice.destroy
    end
  end

  def setup_params(agreement_invoice)
    params[:previous_upcoming_invoice] = agreement_invoice
    params[:payment_agreement_id] = self.payment_agreement.id
  end


  # def create_next_upcoming_invoice(previous_upcoming_invoice)
  #   if next_upcoming_invoice_required(previous_upcoming_invoice)
  #     next_upcoming_invoice = previous_upcoming_invoice.amoeba_dup
  #     optional_params = {invoice_type: previous_upcoming_invoice.invoice_type.name}
  #     # Create trail to log that next upcoming invoice has been created against the previous general/rental_invoice
  #     trail_options = {action: 'upcoming_invoice_created', parent: previous_upcoming_invoice, parent_type: 'Invoice'}
  #     next_upcoming_invoice.invoice_id = nil
  #     if next_upcoming_invoice.save
  #       update_invoice_attributes(previous_upcoming_invoice, next_upcoming_invoice, optional_params)
  #       upcoming_date = invoice_upcoming_date(previous_upcoming_invoice)
  #       if upcoming_date.blank?
  #         add_message :error, 'Cannot set upcoming date'
  #         return
  #       end
  #       set_upcoming_invoice_status(next_upcoming_invoice, true)
  #       set_payment_agreement_upcoming_invoice_date(next_upcoming_invoice, upcoming_date)
  #       set_payment_agreement_upcoming_invoice_due_date(previous_upcoming_invoice, next_upcoming_invoice)
  #       create_trail(trail_options)
  #     end
  #   end
  # end


  # Some attributes are set here, some are nullified in model as per logic used in other places, hence updating explicitly 
  def update_invoice_attributes(original_invoice, new_invoice, options={})
    # receiving_account = self.vendor&.bank_accounts&.first
    role_id = UserRole.id_for(:initiator)

    new_invoice.update(created_by: user, invoice_type_id: InwardInvoiceType.id_for(options[:invoice_type].to_sym), date: original_invoice.payment_agreement_upcoming_date, receiving_account_id: original_invoice.bank_account_id, receiving_account_type: 'BankAccount', controlling_user: user, vendor: vendor, controlling_user_role_id: role_id)
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

  # def set_payment_agreement_upcoming_invoice_date(upcoming_invoice, upcoming_date)
  #   set_upcoming_invoice_status(upcoming_invoice, true)
  #   upcoming_invoice.update(payment_agreement_upcoming_date: upcoming_date)
  # end

  # def set_payment_agreement_upcoming_invoice_due_date(previous_invoice, next_invoice)
  #   due_date = calculate_due_date(previous_invoice)
  #   next_invoice.update(due_date: due_date)
  # end

  # Sets true if payment agreement invoice is upcoming.
  # Set false if actual recurring invoice has been created against payment agreement invoice 
  def set_upcoming_invoice_status(invoice, boolean_status)
    invoice.update(is_payment_agreement_upcoming_invoice: boolean_status)
  end


  # Calculation of due date will be on the basis of previous due date and payment_term
  # due_date = previous_due_date + no_of_day_in_payment_term
  def calculate_due_date(invoice=nil)
    due_date = invoice.payment_agreement_upcoming_date + invoice.payment_term.days_after.to_i
  end

  # def next_upcoming_invoice_required(previous_upcoming_invoice)
  #   previous_upcoming_invoice.billing_type.fixed_periodic? && (self.payment_agreement.no_expiration || invoice_upcoming_date(previous_upcoming_invoice))
  # end


  def validate_vendor(invoice)
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(invoice.vendor_id).first
    if self.vendor.blank?
      add_message :error, 'Vendor not found'
      return
    end
  end

  def update_due_date(actual_invoice, agreement_invoice)
    if agreement_invoice.billing_type.variable_periodic?
      actual_invoice.due_date = Date.today + agreement_invoice.payment_term.days_after
    end
  end

  # Attach agreement item to invoice
  def attach_agreement_item(new_invoice, invoice_type)
    if new_invoice.present?
      new_invoice.payment_agreement_id = self.payment_agreement.id
      new_invoice.agreement_item_type = invoice_type.camelize
      new_invoice.agreement_item_id = payment_agreement_type_id
      new_invoice.save
      CustomField::SetFields.(new_invoice, FieldParentType.id_for(:invoice), reset_fields: true, save: true)
    end
  end

end