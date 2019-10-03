class PaymentAgreements::Base < BaseOperation

  attr_accessor :company, :workflow_output, :payment_agreement, :invoice_freq_num, :match_invoice_start_date, :match_invoice_end_date, :any_fixed_period_general_invoice, :any_fixed_period_rental_invoice


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters, try again'
      return
    end
  end

  def payment_agreement_parameters
    params.require(:payment_agreement).permit(

      :id, :title, :policy_id, :agreement_date, :execution_date, :expiration_date, :renewal_date, :note, :no_expiration, :renewal_reminder_date , :reject_note, :override_order_number,
        selected_invoice_frequency_attributes: {}, 

      general_invoices_attributes: [:id, :_destroy, :department_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :bank_account_id, :note, :billing_start_date, :billing_day_of_month, :discount_type_id, :tds_slab_id, :roundoff_amount, :vendor_id, :due_date, :vendor_location_id, :start_date, :end_date, :lock_in_period, :rent_free_period, :tenancy_period, :prepaid, :escalation_percentage,
        invoice_custom_fields: {},

        invoice_items_attributes: [
            :quantity, :unit_of_measurement, :department_id,
            :cost_center_id, :rate, :tax, :tax_rate_id, :discount,
            :category_id, :description, :id, :remove_line_item,
            :hsn_sac, :comment, :_destroy, :inventory_line_item_id, :tds_applicable,
            discount_amount_attributes: [:id, :currency_id, :value],
            tax_amount_attributes: [:id, :currency_id, :value],
            total_amount_attributes: [:id, :value, :currency_id],
            raw_amount_attributes: [:id, :value, :currency_id]
          ],
        discount_amount_attributes: [:id, :currency_id, :value],
        freight_amount_attributes: [:id, :currency_id, :value],
        tds_amount_attributes: [:id, :currency_id, :value],
        total_after_tax_attributes: [:id, :currency_id, :value],
        advance_amount_attributes: [:id, :currency_id, :value],
        balance_amount_attributes: [:id, :currency_id, :value],
        total_invoice_amount_attributes: [:id, :currency_id, :value],
        extra_charges_attributes: [:id, :currency_id, :value],
        notify_users_attributes: [:id, :_destroy, :user_id],
        # payment_agreement_escalations_attributes: [:id, :period_id, :number, :percentage_increment, :_destroy],
        # payment_agreement_escalation_attributes: [:id, :period_id, :number, :percentage_increment, :_destroy],
        # invoice_frequency_attributes: [:id, :number, :period_id, :_destroy]
      ],
      rental_invoices_attributes: [:id, :_destroy, :department_id, :bank_account_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :note, :vendor_id, :vendor_location_id, :billing_start_date, :billing_day_of_month, :tds_slab_id, :discount_type_id, :due_date, :roundoff_amount, :start_date, :end_date, :lock_in_period, :rent_free_period, :tenancy_period, :square_feet, :notice_period, :prepaid, :escalation_percentage,
        invoice_custom_fields: {},

        invoice_items_attributes: [
            :quantity, :department_id,
            :cost_center_id, :rate, :tax, :tax_rate_id, :discount,
            :category_id, :description, :id, :remove_line_item,
            :hsn_sac, :comment, :_destroy, :inventory_line_item_id, :tds_applicable,
            discount_amount_attributes: [:id, :currency_id, :value], 
            tax_amount_attributes: [:id, :currency_id, :value],
            raw_amount_attributes: [:id, :value, :currency_id]
          ],
        discount_amount_attributes: [:id, :currency_id, :value],
        freight_amount_attributes: [:id, :currency_id, :value],
        tds_amount_attributes: [:id, :currency_id, :value],
        total_after_tax_attributes: [:id, :currency_id, :value],
        advance_amount_attributes: [:id, :currency_id, :value],
        balance_amount_attributes: [:id, :currency_id, :value],
        extra_charges_attributes: [:id, :currency_id, :value],
        notify_users_attributes: [:id, :_destroy, :user_id],
        payment_agreement_escalations_attributes: [:id, :period_id, :number, :percentage_increment, :_destroy],
        # payment_agreement_escalation_attributes: [:id, :period_id, :number, :percentage_increment, :_destroy],
        # invoice_frequency_attributes: [:id, :number, :period_id, :_destroy]
      ],
      beneficiary_payments_attributes: [:id, :_destroy, :vendor_id, :bank_account_id, :cost_center_id, :department_id, :location_id, :note, :vendor_location_id, :tax, :inclusive_of_taxes, :gst_type_id, :tds_slab_id, :renewal_date, :tax_rate_id, 
        tax_amount_attributes: [:id, :value, :currency_id],
        payable_amount_attributes: [:id, :currency_id, :value],
        original_amount_attributes: [:id, :currency_id, :value]

      ],
      security_deposits_attributes: [:id, :_destroy, :vendor_id, :note, :cost_center_id, :department_id, :location_id, :vendor_location_id, :bank_account_id, 
        original_amount_attributes: [:id, :currency_id, :value]
      ]
      
      ).tap do |whitelisted|
        if params.dig(:payment_agreement, :rental_invoices_attributes).present?
          params[:payment_agreement][:rental_invoices_attributes].each_with_index do |rental_invoice, index|
            rental_invoice[:invoice_custom_fields].permit! rescue nil
            # rental_invoice[:custom_fields].permit! rescue nil
            # whitelisted[:rental_invoices_attributes][index][:custom_fields] = rental_invoice[:custom_fields]
          end
        end
        if params.dig(:payment_agreement, :general_invoices_attributes).present?
          params[:payment_agreement][:general_invoices_attributes].each_with_index do |general_invoice, index|
            # general_invoice[:custom_fields].permit! rescue nil
            general_invoice[:invoice_custom_fields].permit! rescue nil
          end
        end
      end
  end

  private

  def update_item_attributes
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.each do |general_invoice|
        update_total_invoice_amount(general_invoice)
        update_amount_attributes(general_invoice)
        set_due_date_for_invoices('general_invoice')
        general_invoice.items.update(department_id: general_invoice.department_id, cost_center_id: general_invoice.cost_center_id)
      end
    end

    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.each do |rental_invoice|
        update_total_invoice_amount(rental_invoice)
        update_amount_attributes(rental_invoice)
        set_due_date_for_invoices('rental_invoice')
        rental_invoice.items.update(department_id: rental_invoice.department_id, cost_center_id: rental_invoice.cost_center_id)
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

    if payment_agreement.beneficiary_payments.present?
      payment_agreement.beneficiary_payments.each do |beneficiary_payment|
      #   update_payable_amount(beneficiary_payment)
      set_due_date_for_beneficiary_payments
      end 
    end

    if payment_agreement.security_deposits.present?
      payment_agreement.security_deposits.each do |security_deposit|
        update_payable_amount(security_deposit)
        set_due_date_for_security_deposits
      end 
    end
  end

  def apply_tds_on_amount(invoice)
    if invoice.tds_slab_id.present?
      tds_percentage = invoice&.tds_slab&.tds.to_f
      tds_value = calculate_tds_value(tds_percentage, invoice)
      item_net_amount_sum = invoice.items.joins(:net_amount).pluck('amounts.value').sum
      # net_amt = item_net_amount_sum - (item_net_amount_sum*tds_percentage/100)
      net_amt = item_net_amount_sum - tds_value
      if invoice.net_amount.present?
        invoice.net_amount.update(value: net_amt)
      else
        invoice.create_net_amount(value: net_amt, currency_id: 1)
      end
    end
  end

  def update_payable_amount(document)
    original_amt = document.original_amount.value
    if document.payable_amount.present?
      document.payable_amount.update(value: original_amt)
    else
      document.create_payable_amount(value: original_amt, currency_id: 1)
    end
  end


  # Invoice Utils calculating wrong amount, need to check
  # Updating explicitly
  def update_balance_due_amount(invoice, amount= nil)
    amount = amount.blank? ? invoice.net_amount.value : amount
    if invoice.balance_due.present?
      invoice.balance_due.update(value: amount)
    else
      invoice.create_balance_due(value: amount, currency_id: 1)
    end
  end

  def set_due_date_for_invoices(invoice_type)
    execution_date = self.payment_agreement&.execution_date&.to_date

    # For non fixed periodic invoices, prepaid flag decides whether invoice upcoming date will be on start date or end date
      self.payment_agreement.send(invoice_type.pluralize.to_sym).each do |invoice|
        unless invoice.billing_type.fixed_periodic?
          if invoice.prepaid
            invoice.update(payment_agreement_upcoming_date: invoice.start_date)
          else
            invoice.update(payment_agreement_upcoming_date: invoice.end_date)
          end
        end
      end


    # self.payment_agreement.general_invoices.map do |general_invoice|
      # number = general_invoice.invoice_frequency&.number
      # period_id = general_invoice.invoice_frequency&.period_id
      # billing_start_date = general_invoice.billing_start_date&.to_date
      
      # Set rules for calculation of payment date based on period set
      # During create and update of payment_agreement i.e. during adding/updating agreement items, use execution date to set the first due date
      # Once agreement is approved, no agreement items should be added
      # general_invoice.update(payment_agreement_upcoming_date: execution_date)


      # case 
      # when period_id == Period.id_for(:month)
      #   due_date = billing_start_date
      #   general_invoice.update(payment_agreement_upcoming_date: due_date) if due_date.present?
      # end
    # end
  end

  def set_due_date_for_general_invoices
    execution_date = self.payment_agreement&.execution_date&.to_date

    # For non fixed periodic invoices, prepaid flag decides whether invoice upcoming date will be on start date or end date
      self.payment_agreement.general_invoices.each do |general_invoice|
        if general_invoice.billing_type.fixed_periodic? 
          # To set first due date, create general invoice
          create_invoice_template
        else
          if general_invoice.prepaid
            general_invoice.update(payment_agreement_upcoming_date: general_invoice.start_date)
          else
            general_invoice.update(payment_agreement_upcoming_date: general_invoice.end_date)
          end
        end
      end


    # self.payment_agreement.general_invoices.map do |general_invoice|
      # number = general_invoice.invoice_frequency&.number
      # period_id = general_invoice.invoice_frequency&.period_id
      # billing_start_date = general_invoice.billing_start_date&.to_date
      
      # Set rules for calculation of payment date based on period set
      # During create and update of payment_agreement i.e. during adding/updating agreement items, use execution date to set the first due date
      # Once agreement is approved, no agreement items should be added
      # general_invoice.update(payment_agreement_upcoming_date: execution_date)


      # case 
      # when period_id == Period.id_for(:month)
      #   due_date = billing_start_date
      #   general_invoice.update(payment_agreement_upcoming_date: due_date) if due_date.present?
      # end
    # end
  end

  def set_due_date_for_rental_invoices
    execution_date = self.payment_agreement&.execution_date&.to_date
    # self.payment_agreement.rental_invoices.map {|rental_invoice| rental_invoice.update(payment_agreement_upcoming_date: execution_date, is_payment_agreement_upcoming_invoice: true)}

    # Any one invoice will have start date equivalent to execution date. This is the first agreement invoice to be processed. Hence, it is first upcoming invoice.
      self.payment_agreement.rental_invoices.where(start_date: execution_date).update_all(payment_agreement_upcoming_date: execution_date, is_payment_agreement_upcoming_invoice: true)

    # self.payment_agreement.rental_invoices.map do |rental_invoice|
      # number = rental_invoice.invoice_frequency&.number
      # period_id = rental_invoice.invoice_frequency&.period_id
      # billing_start_date = rental_invoice.billing_start_date&.to_date
      # rental_invoice.update(payment_agreement_upcoming_date: execution_date)


      # Set rules for calculation of payment date based on period set
      # case 
      # when period_id == Period.id_for(:month)
      #   due_date = billing_start_date
      #   rental_invoice.update(payment_agreement_upcoming_date: due_date) if due_date.present?
      # end
    # end
  end


  def set_due_date_for_beneficiary_payments
    execution_date = payment_agreement.execution_date&.to_date
    self.payment_agreement.beneficiary_payments.map {|beneficiary_payment| beneficiary_payment.update(payment_agreement_upcoming_date: execution_date)}
  end

  def set_due_date_for_security_deposits
    execution_date = payment_agreement.execution_date&.to_date
    self.payment_agreement.security_deposits.map {|security_deposit| security_deposit.update(payment_agreement_upcoming_date: execution_date)}

    # self.payment_agreement.security_deposits.map do |security_deposit|
      
    #   security_deposit.update(payment_agreement_upcoming_date: execution_date)
    # end
  end

  def update_line_item_attributes
    # self.payment_agreement.general_invoices.map{|general_invoice| general_invoice.items.update(department_id: general_invoice.department_id, cost_center_id: general_invoice.cost_center_id)} if self.payment_agreement.general_invoices.present?
    # self.payment_agreement.rental_invoices.map{|rental_invoice| rental_invoice.items.update(department_id: rental_invoice.department_id, cost_center_id: rental_invoice.cost_center_id)} if self.payment_agreement.rental_invoices.present?
  end

  def calculate_tds_value(tds_percentage, invoice)
    amount_arr = []
    # Get value from line items
    invoice.items.each do |item|
      if item.discount.present?
        amt = (item.rate * item.quantity) - (item.rate * item.quantity*item.discount/100)
      else
        amt = (item.rate * item.quantity)
      end
      amount_arr << amt*tds_percentage/100
    end
    return amount_arr.sum
  end

  # Calculate and set total amount on payment agreements
  def update_total_amount
    total_amount = agreement_item_total_amount
    if self.payment_agreement.total_amount.present?
      self.payment_agreement.total_amount.update(value: total_amount)
    else
      # TODO - check why this is not working
      # self.payment_agreement.create_total_amount(value: total_amount, currency_id: 1)
      amount = Amount.create(value: total_amount, currency_id: 1)
      payment_agreement.total_amount_id = amount.id
      payment_agreement.save
    end
  end

  # Agreement items can have multiple combinations, hence consider all of them for approval flow threshold validation
  def agreement_item_total_amount
    item_max = []

    if self.payment_agreement.security_deposits.present?
      ids = self.payment_agreement.security_deposits.pluck(:payable_amount_id)
      sd_total_amount = Amount.where(id: ids).pluck(:value).max
      item_max << sd_total_amount if sd_total_amount.present?
    end

    if self.payment_agreement.general_invoices.present?
      ids = self.payment_agreement.general_invoices.pluck(:balance_due_id)
      gi_total_amount = Amount.where(id: ids).pluck(:value).max
      item_max << gi_total_amount if gi_total_amount.present?
    end

    if self.payment_agreement.rental_invoices.present?
      ids = self.payment_agreement.general_invoices.pluck(:balance_due_id)
      ri_total_amount = Amount.where(id: ids).pluck(:value).max
      item_max << ri_total_amount if ri_total_amount.present?
    end

    if self.payment_agreement.beneficiary_payments.present?
      ids = self.payment_agreement.beneficiary_payments.pluck(:payable_amount_id)
      bp_total_amount = Amount.where(id: ids).pluck(:value).max
      item_max << bp_total_amount if bp_total_amount.present?
    end

    return item_max.max
  end

  # Invoice can be of type general or rental
  def update_amount_attributes(invoice)
    update_taxable_and_orig_amount_value(invoice)
    invoice.items.map(&:update_taxable_amount_value)
    # InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
    # invoice.save
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
    invoice.save
    if invoice.tds_slab_id.present?
      apply_tds_on_amount(invoice)
    end
    update_balance_due_amount(invoice, invoice.net_amount.value)
  end

  def update_taxable_and_orig_amount_value(invoice)
    taxable_val = []
    raw_val = []
    if invoice.items.present?
      invoice.items.each do |item|
        rate = item.rate
        quantity = item.quantity
        discount_percentage = item.discount
        amount_before_discount = rate*quantity
        taxable_amt = amount_before_discount - (amount_before_discount*item.discount.to_f/100)
        raw_val << amount_before_discount
        taxable_val << taxable_amt
      end
    end

    if invoice.original_amount.present?
      invoice.original_amount.update(value: raw_val.sum)
    else
      invoice.create_original_amount(value: raw_val.sum, currency_id: 1)
    end
    
    if invoice.taxable_amount.present?
      invoice.taxable_amount.update(value: taxable_val.sum)
    else
      invoice.create_taxable_amount(value: taxable_val.sum, currency_id: 1)
    end
  end


  def create_or_update_custom_fields
    # Setup custom field for general invoices
    if self.payment_agreement.general_invoices.present?
      if params.dig(:payment_agreement, :general_invoices_attributes).present?
        self.payment_agreement.general_invoices.each_with_index do |invoice, index|
          custom_fields = invoice.invoice_custom_fields
          if custom_fields.present?
            if invoice.new_record?
              custom_fields_data = {custom_fields: custom_fields, user: user, save: false, reset_fields: true}
              # CustomField::SetFields.(invoice, FieldParentType.id_for(:general_invoice), custom_fields_data)
              validate_custom_fields_invoice(invoice, custom_fields, false)
            else
              validate_custom_fields_invoice(invoice, custom_fields, false)
            end
          end
        end
      end
    end

    # Setup custom field for rental invoices
    if self.payment_agreement.rental_invoices.present?
      if params.dig(:payment_agreement, :rental_invoices_attributes).present?
        self.payment_agreement.rental_invoices.each_with_index do |invoice, index|
          custom_fields = invoice.invoice_custom_fields
          if custom_fields.present?
            if invoice.new_record?
              # custom_fields = params[:payment_agreement][:rental_invoices_attributes][index][:custom_fields]
              custom_fields_data = {custom_fields: custom_fields, user: user, save: false, reset_fields: true}
              # CustomField::SetFields.(invoice, FieldParentType.id_for(:rental_invoice), custom_fields_data)
              validate_custom_fields_invoice(invoice, custom_fields, false)
            else
              # custom_fields = params[:payment_agreement][:rental_invoices_attributes][index][:custom_fields]
              validate_custom_fields_invoice(invoice, custom_fields, false)
            end
          end
        end
      end
    end
  end

  def validate_custom_fields_invoice(invoice, custom_fields, save=false)
    set_fields = set_custom_fields_invoice invoice, custom_fields, save
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(invoice)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields_invoice(invoice, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(invoice, FieldParentType.id_for(invoice.class.name.underscore.to_sym), custom_fields)
  end

  # Invoice frequency should be same for all agreement items. E.g. If agreement has four rentals under fixed periodic, all rental should have same invoice frequency
  def validate_invoice_frequency

    validate_invoice_frequency_for_gi
    validate_invoice_frequency_for_ri
  end

  def validate_invoice_frequency_for_gi
    if self.payment_agreement.general_invoices.fixed_periodic_type.present?
      self.invoice_freq_num = []
      self.payment_agreement.general_invoices.fixed_periodic_type.each do |general_invoice|
        if self.payment_agreement.selected_invoice_frequency_attributes["invoice_frequency_value"].present?
          clear_frequency_for_document(general_invoice)
          validate_frequency_for_document(general_invoice)
        end
      end
      # validate_frequency_based_start_end_date('general_invoice')
    end
  end

  def validate_invoice_frequency_for_ri
    if self.payment_agreement.rental_invoices.fixed_periodic_type.present?
      self.invoice_freq_num = []
      self.payment_agreement.rental_invoices.fixed_periodic_type.each do |rental_invoice|
        if self.payment_agreement.selected_invoice_frequency_attributes["invoice_frequency_value"].present?
          clear_frequency_for_document(rental_invoice)
          validate_frequency_for_document(rental_invoice)
        end
      end
      # validate_frequency_based_start_end_date('rental_invoice')
    end
  end

  def validate_frequency_based_start_end_date(invoice_type)
    return if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.blank?
    # Invoice frequency should be no more than inv frequency months
    # First invoice can be less than inv frequency months
    # Difference between month should always be equal to invoice frequency months
    vendor_ids = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.pluck(:vendor_id).uniq
    invoice_frequency = get_invoice_frequency(invoice_type)
    validate_start_date_and_execution_date(invoice_type)
    validate_end_date_end_expiration_date(invoice_type)
    return if has_errors?
    vendor_ids.each do |vendor_id|
      dates = self.payment_agreement.send(invoice_type.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.order(:start_date).collect{ |invoice| [invoice.start_date, invoice.end_date] }
      last_end_date = self.payment_agreement.send(invoice_type.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.order(:start_date).last.end_date
      total_vendor_records_count = self.payment_agreement.send(invoice_type.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.count
      dates.each.with_index(1) do |date, index|
        return if has_errors?
        start_date, end_date = date[0], date[1]
        start_date_month, end_date_month = date[0].month, date[1].month
        # First record or if only one record is present, start date and end date should not fall in some month
        # if index == 1
        #   unless start_date == self.payment_agreement.execution_date.to_date
        #     add_message :error, "First start date: #{start_date} for vendor #{YesBankVendor.find(vendor_id).display_name} should be equal to execution date: #{self.payment_agreement.execution_date.to_date}"
        #     return
        #   end
        #   if start_date_month == end_date_month
        #     add_message :error, "Start date and end date for vendor #{YesBankVendor.find(vendor_id).display_name} cannot be in same month"
        #     return
        #   end
        # end
        # # for last end date
        # if (index == dates.count)
        #   unless self.payment_agreement.no_expiration
        #     if self.payment_agreement.expiration_date.present?
        #       unless end_date == self.payment_agreement.expiration_date.to_date
        #         add_message :error, "Last end date: #{end_date} should be equal to expiration date: #{self.payment_agreement.expiration_date.to_date} for vendor #{YesBankVendor.find(vendor_id).display_name}"
        #       end
        #     end
        #   end
        # end
        # Except for first and last record, invoice start date should be start of month and end date should be end of month
        unless index == 1
          unless validate_start_date_as_start_of_month(start_date, dates, index)
            add_message :error, "Start date: #{start_date} should be start of month for vendor #{YesBankVendor.find(vendor_id).display_name}"
          end
        end
        unless index == total_vendor_records_count
          unless validate_end_date_as_end_of_month(end_date,last_end_date)
            add_message :error, "End date: #{end_date} should be end of month for vendor #{YesBankVendor.find(vendor_id).display_name}"
          end
          unless  (end_date_month - start_date_month + 1) % (invoice_frequency) == 0
            add_message :error, "Difference between start date(#{start_date}) and end date(#{end_date}) should be equal to invoice frequency or its multiples"
            return
          end
        end 


      end
    end
  end

  # Clear invoice frequency if already present if billing type is not fixed_periodic 
  def clear_frequency_for_document(invoice)
    unless invoice.billing_type.fixed_periodic?
      invoice.invoice_frequency = nil
    end
  end

  def validate_frequency_for_document(invoice)
    if invoice.billing_type.fixed_periodic?
      # Jugaad as frontend is failing, push this selected attribute to all agreement invoices
      updated_invoice_with_frequency = set_selected_invoice_frequency_attributes(invoice)
      if updated_invoice_with_frequency.blank?
        add_message :error, "Internal error, unable to set invoice frequency"
        return
      end
      if updated_invoice_with_frequency.present?
        invoice = updated_invoice_with_frequency
      end 

      invoice_freq_num << invoice.invoice_frequency.number
      if invoice_freq_num.uniq.count.zero?
        add_message :error,  "#{invoice.class.name.titleize} frequency data is incorrect"
        return 
      end
      if invoice_freq_num.uniq.count > 1
        add_message :error, "Invoice frequency should be same for all #{invoice.class.name.titleize.pluralize}"
        return
      end
    end
  end

  # Invoice start date and end date should cover all days between agreement execution date and agreement expiration date

  def validate_invoice_start_end_date
    if self.payment_agreement.general_invoices.present?
      general_invoice_start_end_date
    end
    if self.payment_agreement.rental_invoices.present?
      rental_invoice_start_end_date
    end
  end

  # def general_invoice_start_end_date
  #   if self.payment_agreement.general_invoices.present?
  #     self.match_invoice_start_date = false
  #     self.match_invoice_end_date = false #false
  #     self.any_fixed_period_general_invoice = false
  #     # start_end_date_arr => Keeps all the start_date and end_date as 2d array
  #     # start_end_date_arr = []
      
  #     # Order of validation is creating confusion, hence - till we have partial invoice in place
  #     # if self.payment_agreement.general_invoices.present?
  #     #   if (self.payment_agreement.general_invoices.first.billing_type.fixed_periodic?) && self.payment_agreement.general_invoices.first.start_date.present? && self.payment_agreement.execution_date.present?
  #     #     unless self.payment_agreement.general_invoices.first.start_date.to_date == self.payment_agreement.execution_date.to_date
  #     #       add_message :error, "First general invoice start date should be equal to execution date"
  #     #         return
  #     #     end
  #     #   end
  #     # end
      
  #     self.payment_agreement.general_invoices.each do |general_invoice|
  #       # start_end_date_arr.push([general_invoice.start_date.to_date, general_invoice.end_date.to_date])
  #       unless self.any_fixed_period_general_invoice
  #         self.any_fixed_period_general_invoice = general_invoice.billing_type.fixed_periodic?
  #       end 
  #       comparison_status = compare_start_end_date(general_invoice)
  #       return unless comparison_status
  #       # match_start_date, match_end_date = check_missing_days(general_invoice)
  #       check_missing_days(general_invoice)
  #       if general_invoice.billing_type.fixed_periodic?
  #         return if self.match_invoice_start_date
  #       end
  #       return if self.match_invoice_start_date && self.match_invoice_end_date
  #     end

  #     if self.any_fixed_period_general_invoice
  #       add_message :error, "Any one general invoice start date should match with execution date"
  #       return
  #     end



  #     # if self.invoice.billing_type.one_time?
  #     #   if unless self.payment_agreement.no_expiration
  #     #     add_message :error, "Any one general invoice start date should match with execution date"
  #     #     return
  #     #   end
  #     #   add_message :error, "Any one general invoice start and end date should match with execution and expiration date"
  #     #   return
  #     # end

  #     # if self.invoice.billing_type.variable_periodic?
  #     #   if unless self.payment_agreement.no_expiration
  #     #     add_message :error, "Any one general invoice start date should match with execution date"
  #     #     return
  #     #   end
  #     #   add_message :error, "Any one general invoice start and end date should match with execution and expiration date"
  #     #   return
  #     # end

  #     # Scope it for fixed periodic only till partial invoice is handled 
  #     # if self.payment_agreement.no_expiration
  #     #   add_message :error, "Any one general invoice start date should match with execution date"
  #     #   return
  #     # end

  #     # add_message :error, "Any one general invoice start and end date should match with execution and expiration date"
  #     # return
  #   end
  # end

  def general_invoice_start_end_date
    dates = self.payment_agreement.general_invoices.pluck(:start_date, :end_date)
    validate_all_dates(dates)
    validate_frequency_based_start_end_date('general_invoice')
    validate_invoice_frequency_for_gi
    # vendor_ids = self.payment_agreement.general_invoices.pluck(:vendor_id).uniq
    # return if has_errors?
    # vendor_ids.each do |vendor_id|
    #   return if has_errors?
    #   self.payment_agreement.general_invoices.where(vendor_id: vendor_id).each{ |general_invoice| compare_start_end_date(general_invoice, vendor_id) }
    # end
  end

  def rental_invoice_start_end_date
    dates = self.payment_agreement.general_invoices.pluck(:start_date, :end_date)
    validate_all_dates(dates)
    validate_invoice_frequency_for_ri
    # vendor_ids = self.payment_agreement.rental_invoices.pluck(:vendor_id).uniq
    validate_frequency_based_start_end_date('rental_invoice')
    # return if has_errors?
    # vendor_ids.each do |vendor_id|
    #   return if has_errors?
    #   self.payment_agreement.rental_invoices.where(vendor_id: vendor_id).each{ |rental_invoice| compare_start_end_date(rental_invoice, vendor_id) }
    # end
  end

  # def rental_invoice_start_end_date
  #   if self.payment_agreement.rental_invoices.present?
  #     self.match_invoice_start_date = false
  #     self.match_invoice_end_date = false
  #     self.any_fixed_period_rental_invoice = false

  #     # Order of validation is creating confusion, hence - till we have partial invoice in place
  #     if self.payment_agreement.rental_invoices.present?
  #       if (self.payment_agreement.rental_invoices.first.billing_type.fixed_periodic?) && self.payment_agreement.rental_invoices.first.start_date.present? && self.payment_agreement.execution_date.present?
  #         unless self.payment_agreement.rental_invoices.first.start_date.to_date == self.payment_agreement.execution_date.to_date
  #           add_message :error, "First rental invoice start date should be equal to execution date"
  #             return
  #         end
  #       end
  #     end


  #     self.payment_agreement.rental_invoices.each do |rental_invoice|
  #       unless self.any_fixed_period_rental_invoice
  #         self.any_fixed_period_rental_invoice = rental_invoice.billing_type.fixed_periodic?
  #       end 
  #       comparison_status = compare_start_end_date(rental_invoice)
  #       return unless comparison_status
  #       # match_start_date, match_end_date = check_missing_days(rental_invoice)
  #       check_missing_days(rental_invoice)
  #       if rental_invoice.billing_type.fixed_periodic?
  #         return if self.match_invoice_start_date
  #       end
  #       return if self.match_invoice_start_date && self.match_invoice_end_date
  #     end


  #     if self.any_fixed_period_rental_invoice
  #       add_message :error, "Any one rental invoice start date should match with execution date"
  #       return
  #     end

  #     # if self.invoice.billing_type.one_time?
  #     #   if unless self.payment_agreement.no_expiration
  #     #     add_message :error, "Any one rental invoice start date should match with execution date"
  #     #     return
  #     #   end
  #     #   add_message :error, "Any one rental invoice start and end date should match with execution and expiration date"
  #     #   return
  #     # end

  #     # if self.invoice.billing_type.variable_periodic?
  #     #   if unless self.payment_agreement.no_expiration
  #     #     add_message :error, "Any one rental invoice start date should match with execution date"
  #     #     return
  #     #   end
  #     #   add_message :error, "Any one rental invoice start and end date should match with execution and expiration date"
  #     #   return
  #     # end
  #     # if self.payment_agreement.no_expiration
  #     #   add_message :error, "Any one rental invoice start date should match with execution date"
  #     #   return
  #     # end

  #     # add_message :error, "Any one rental invoice start and end date should match with execution and expiration date"
  #     # return
  #   end
  # end

  # def rental_invoice_start_end_date
  #   if self.payment_agreement.rental_invoices.present?
  #     self.match_invoice_start_date = false
  #     self.match_invoice_end_date = false
  #     self.any_fixed_period_invoice = false
  #     self.payment_agreement.rental_invoices.each do |rental_invoice|
  #       unless self.any_fixed_period_invoice
  #         self.any_fixed_period_invoice = rental_invoice.billing_type.fixed_periodic?
  #       end 
  #       comparison_status = compare_start_end_date(rental_invoice)
  #       return unless comparison_status
  #       match_start_date, match_end_date = check_missing_days(rental_invoice)
  #       if rental_invoice.billing_type.fixed_periodic?
  #         return if match_start_date
  #       end
  #       return if match_start_date && match_end_date
  #     end
  #     if self.any_fixed_period_invoice
  #       add_message :error, "Any one rental invoice start date should match with execution date"
  #       return
  #     end
  #     add_message :error, "Any one rental invoice start and end date should match with execution and expiration date"
  #     return
  #   end
  # end


  # Start date and end date should be between agreement execution date and expiration date
  # def compare_start_end_date(invoice, vendor_id)
  #   validate_frequency_for_document(invoice) #TODO - REMOVE
  #   if invoice.start_date.present? && invoice.end_date.present? && self.payment_agreement.execution_date.present? && (self.payment_agreement.expiration_date.present? || self.payment_agreement.no_expiration)
  #     # if (invoice.start_date&.to_date < self.payment_agreement.execution_date&.to_date)
  #     #   add_message :error, "#{invoice.class.name.titleize} start date is not in between execution and expiration date"
  #     #   return false
  #     # end

  #     # unless self.payment_agreement.no_expiration
  #     #   if invoice.start_date&.to_date > self.payment_agreement.expiration_date&.to_date
  #     #     add_message :error, "#{invoice.class.name.titleize} start date is not in between execution and expiration date"
  #     #     return false
  #     #   end
  #     # end

  #     # if invoice.end_date&.to_date < self.payment_agreement.execution_date&.to_date
  #     #   add_message :error, "#{invoice.class.name.titleize} end date cannot be less than execution date"
  #     #   return false
  #     # end

  #     # unless self.payment_agreement.no_expiration
  #     #   if invoice.end_date&.to_date > self.payment_agreement.expiration_date&.to_date
  #     #     add_message :error, "#{invoice.class.name.titleize} end date cannot be more than expiration date"
  #     #     return false
  #     #   end
  #     # end

  #     if invoice.end_date&.to_date < invoice.start_date&.to_date
  #       add_message :error, "#{invoice.class.name.titleize} end date cannot be before start date"
  #       return false
  #     end

  #     # Difference between start date and end date should be in the multiples for invoice frequency
  #     # For fixed periodic only

  #     if invoice.billing_type.fixed_periodic?
  #       frequency_period_number = invoice&.invoice_frequency&.number
  #       match_end_date_with_frequency_multiple = false
  #       if frequency_period_number.blank?
  #         add_message :error, "Invoice frequency cannot be blank"
  #         return
  #       end

  #         expected_end_date_present = false
  #         more_than_one_invoice = false

  #         # End date is not in mulltiples of invoice frequency
  #         # End date is not considered is no_expiration is true and only one invoice is present
  #         invoice_count = self.payment_agreement.send(invoice.class.name.underscore.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.count
  #         if invoice_count > 1
  #           more_than_one_invoice = true
  #         end

  #         # if invoice.is_a?(GeneralInvoice)
  #         #   if self.payment_agreement.general_invoices.size > 1
  #         #     more_than_one_invoice = true
  #         #   end
  #         # end
  #         # if invoice.is_a?(RentalInvoice)
  #         #   if self.payment_agreement.rental_invoices.size > 1
  #         #     more_than_one_invoice = true
  #         #   end
  #         # end


  #         return unless more_than_one_invoice
  #         #return if first start date as invoice can start from mid of month, it is not necessary for it to be start of month
  #         # return if invoice.start_date.to_date == self.payment_agreement.send(invoice.class.name.underscore.pluralize.to_sym).order(:start_date).first.start_date.to_date
  #         #Return if last end date as it is not necesary to be end of month 
  #         # return if invoice.end_date.to_date == self.payment_agreement.send(invoice.class.name.underscore.pluralize.to_sym).order(:end_date).last.end_date.to_date
  #         unless invoice.start_date.to_date == self.payment_agreement.send(invoice.class.name.underscore.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.order(:start_date).first.start_date.to_date
  #           if invoice.start_date.day != 1
  #             add_message :error, "Start date: #{invoice.start_date} should be start of month(eg: #{invoice.start_date.beginning_of_month})"
  #             return
  #           end
  #         end
  #         unless invoice.end_date.to_date == self.payment_agreement.send(invoice.class.name.underscore.pluralize.to_sym).where(vendor_id: vendor_id).fixed_periodic_type.order(:end_date).last.end_date.to_date
  #           if invoice.end_date.day != invoice.end_date.end_of_month.day
  #             add_message :error, "End date: #{invoice.end_date} should be end of month(eg: #{invoice.end_date.end_of_month})"
  #             return
  #           end
  #         end

  #         # (1..12).to_a.each do |number|
  #         #   # Work around because no of days are not defined in a month and currently partial invoice is not in place
  #         #   # Pls check invoice value when making any changes here. 
  #         #   # Currently one month is defined as one day before that date next month.
  #         #   unless self.payment_agreement.no_expiration
  #         #     next if invoice.end_date.to_date == self.payment_agreement.expiration_date.to_date
  #         #   end

  #         #   ############## Obselete Logic Start #####################
  #         #   if number%frequency_period_number == 0
  #         #     if invoice.end_date.to_date == (invoice.start_date.to_date + number.month - 1.day)
  #         #       # If not already true
  #         #       unless match_end_date_with_frequency_multiple
  #         #         match_end_date_with_frequency_multiple = true
  #         #       end
  #         #       if invoice.end_date.to_date < (invoice.start_date.to_date + frequency_period_number.month - 1.day)
  #         #         add_message :error, "Duration between start and end date cannot be less than #{frequency_period_number} months as per frequency"
  #         #         add_message :error, "Next end date for start date: #{invoice.start_date.to_date} is #{invoice.start_date.to_date + frequency_period_number.month - 1.day} or its muliples"
  #         #         return
  #         #       end


  #         #       unless expected_end_date_present
  #         #         expected_end_date_present = true
  #         #       end
  #         #     end
  #         #   end
  #         #   ############# Obselete Logic End ##########################
  #         # end
  #         # if more_than_one_invoice
  #         #   unless expected_end_date_present
  #         #     add_message :error, "Start and End date difference should be in multiples of invoice frequency(#{frequency_period_number} months)"
  #         #     return
  #         #   end
  #         # end

  #         # # If  one invoice
  #         # unless more_than_one_invoice
  #         #   if invoice.end_date.to_date < (invoice.start_date.to_date + frequency_period_number.month - 1.day)
  #         #     add_message :error, "Duration between start and end date cannot be less than #{frequency_period_number} months as per frequency"
  #         #     return
  #         #   end
  #         #   # unless expected_end_date_present
  #         #   #   add_message :error, "Next end date for start date: #{invoice.start_date.to_date} is #{invoice.start_date.to_date + frequency_period_number.month - 1.day} or its muliples"
  #         #   #   return
  #         #   # end
  #         # end
  #       # end
  #     end

  #   end
  #   true
  # end


  # Start date and end date should cover all days between agreement execution date and expiration date
  # Enforce user to add any one invoice start date as execution date and any invoice end date as expiration date
  # def check_missing_days(invoice)
  #   if invoice.start_date.present? && invoice.end_date.present? && self.payment_agreement.execution_date.present? && (self.payment_agreement.expiration_date.present? || self.payment_agreement.no_expiration)
  #     unless [BillingType.id_for(:one_time), BillingType.id_for(:variable_periodic)].include?(invoice.billing_type_id)
  #       if invoice.start_date&.to_date == self.payment_agreement.execution_date&.to_date
  #         unless match_invoice_start_date 
  #           self.match_invoice_start_date = true
  #         end
  #       end
  #     else
  #       self.match_invoice_start_date = true
  #     end
  #     # If agreement never expires, do not match expiration date with end date
  #     if self.payment_agreement.no_expiration
  #       self.match_invoice_end_date = true
  #       return match_invoice_start_date, match_invoice_end_date
  #     end
  #     # Not required as we are not comparing end date any more
  #     unless [BillingType.id_for(:one_time), BillingType.id_for(:variable_periodic)].include?(invoice.billing_type_id)
  #       if invoice.end_date&.to_date == self.payment_agreement.expiration_date&.to_date
  #         unless match_invoice_end_date
  #           self.match_invoice_end_date = true
  #         end
  #       end
  #     else
  #       self.match_invoice_end_date = true
  #     end
  #   end
  #   return match_invoice_start_date, match_invoice_end_date
  # end

  def check_agreement_item_presence
    if payment_agreement.general_invoices.blank? && payment_agreement.rental_invoices.blank? && payment_agreement.security_deposits.blank? && payment_agreement.beneficiary_payments.blank?
      add_message :error, 'Please add agreement item'
      return false
    end
    true
  end

  # Check for consecutiveness for fixed periodic invoice type
  # start_date starts from the very end of previous end_date
  # def validate_start_end_date_consecutiveness
  #   if self.payment_agreement.general_invoices.fixed_periodic_type.present?
  #     gi_start_end_date_consecutiveness
  #   end
  #   if self.payment_agreement.rental_invoices.fixed_periodic_type.present?
  #     ri_start_end_date_consecutiveness
  #   end
  # end

  # def gi_start_end_date_consecutiveness
  #   vendor_ids = self.payment_agreement.general_invoices.fixed_periodic_type.pluck(:vendor_id).uniq
  #   vendor_ids.each do |vendor_id|
  #     return if has_errors?
  #     # dates = self.payment_agreement.general_invoices.pluck(:start_date, :end_date)
  #     dates = self.payment_agreement.general_invoices.fixed_periodic_type.where(vendor_id: vendor_id).order(:start_date).collect{ |invoice| [invoice.start_date, invoice.end_date] }
  #     if dates.present? and dates.count > 1
  #       # Check consecutiveness for fixed periodic only
  #       # return unless [self.payment_agreement.general_invoices.pluck(:billing_type_id)].include?(BillingType.id_for(:fixed_periodic))
  #       return unless self.payment_agreement.general_invoices.fixed_periodic_type.where(vendor_id: vendor_id).order(:start_date).collect{ |invoice| invoice.billing_type_id}.include?(BillingType.id_for(:fixed_periodic))
  #       invoice_start_end_date_consecutiveness(dates)
  #     end
  #   end
  # end

  # def ri_start_end_date_consecutiveness
  #   vendor_ids = self.payment_agreement.rental_invoices.fixed_periodic_type.pluck(:vendor_id).uniq
  #   vendor_ids.each do |vendor_id|
  #     return if has_errors?
  #     dates = self.payment_agreement.rental_invoices.fixed_periodic_type.where(vendor_id: vendor_id).order(:start_date).collect{ |invoice| [invoice.start_date, invoice.end_date] }
  #     if dates.present? and dates.count > 1
  #       # Check consecutiveness for fixed periodic only
  #       # return unless [self.payment_agreement.rental_invoices.pluck(:billing_type_id)].include?(BillingType.id_for(:fixed_periodic))
  #       return unless self.payment_agreement.rental_invoices.fixed_periodic_type.where(vendor_id: vendor_id).order(:start_date).collect{ |invoice| invoice.billing_type_id}.include?(BillingType.id_for(:fixed_periodic))
  #       invoice_start_end_date_consecutiveness(dates)
  #     end
  #   end
  # end

  # Compare every date with other start_date and end_date and check for overlapping
  # Document is invalid if overlapping of dates are there
  # def invoice_start_end_date_consecutiveness(dates)
  #   execution_date = self.payment_agreement.execution_date.to_date rescue nil
  #   expiration_date = self.payment_agreement.expiration_date.to_date rescue nil
  #   dates.each_with_index do |current_date_arr, current_index|
  #     next_start_date_present = false
  #     next_end_date_present = false
  #     start_date = current_date_arr[0].to_date
  #     end_date = current_date_arr[1].to_date
  #     date_with_issues = []

  #     # if execution_date.present?
  #     #   if start_date < execution_date
  #     #     add_message :error, "Start date cannot be less than execution date"
  #     #     return
  #     #   end
  #     # end

  #     # if expiration_date.present?
  #     #   if end_date > expiration_date
  #     #     add_message :error, "End date cannot be more than expiration date"
  #     #     return 
  #     #   end
  #     # end

  #     # Do not put check for last end date for consecutiveness 
  #     # next if dates.index(dates.last) == current_index

  #     # compare current_date_arr start_date and end_date with all the dates in the agreement invoice
  #     dates.each_with_index do |date_arr, index|
  #       # Skip comparison with itself
  #       next if index == current_index
  #       # check if start date lies in b/w start date and end date of any other document
  #       if start_date >= date_arr[0].to_date && start_date <= date_arr[1].to_date
  #         date_with_issues << start_date
  #         add_message :error, "Start date: #{start_date} is coming between #{date_arr[0].to_date} and #{date_arr[1].to_date} in an invoice"
  #         return
  #       end

  #       if end_date >= date_arr[0].to_date && end_date <= date_arr[1].to_date
  #         date_with_issues << end_date
  #         add_message :error, "End date: #{end_date} is coming between #{date_arr[0].to_date} and #{date_arr[1].to_date} in an invoice"
  #         return
  #       end
  #       unless next_start_date_present
  #         if end_date + 1.day == date_arr[0].to_date
  #           next_start_date_present = true
  #           break
  #         end
  #       end

  #       # unless next_end_date_present
  #       #   if start_date + 1.day == date_arr[0].to_date
  #       #     next_start_date_present = true
  #       #   end
  #       # end
  #     end
  #     if self.payment_agreement.no_expiration || (self.payment_agreement.expiration_date.to_date >= end_date) 
  #       unless next_start_date_present
  #         add_message :error, "Fixed periodic start and end date should be consecutive"
  #         # add_message :error, "One of the start date should be #{end_date+1.day}"
  #         return
  #       end
  #     end
  #     break unless date_with_issues.blank?
  #   end
  # end

  def billing_type_validations
    general_invoice_billing_type_validation
    rental_invoice_billing_type_validation
  end

  # If any general invoice has billing type fixed periodic, then all general invoices should have same billing type with same invoice_frequency

  # If billing type is one_time or variable_periodic, they can co-exist for single agreement
  def general_invoice_billing_type_validation
    if self.any_fixed_period_general_invoice
      billing_type_ids = self.payment_agreement.general_invoices.collect{|invoice| invoice.billing_type_id}.uniq rescue [] 
      if billing_type_ids.count > 1 && billing_type_ids.include?(BillingType.id_for(:fixed_periodic))
        add_message :error, "All general invoices should have billing type as fixed periodic"
        return
      end
    end
  end

  def rental_invoice_billing_type_validation
    if self.any_fixed_period_rental_invoice
      billing_type_ids = self.payment_agreement.rental_invoices.collect{|invoice| invoice.billing_type_id}.uniq
      if billing_type_ids.count > 1 && billing_type_ids.include?(BillingType.id_for(:fixed_periodic))
        add_message :error, "All rental invoices should have billing type as fixed periodic"
        return
      end
    end
  end

  # If expiration date is present and agreement never expires, clear expiration date
  def clear_expiration_date_on_no_expiration
    if self.payment_agreement.no_expiration
      if self.payment_agreement.expiration_date.present?
        self.payment_agreement.expiration_date = nil
      end
    end
  end

  # General and rental invoice should not co-exist in an agreement
  # security and beneficiary should not co-exist in an agreement
  # There combinations can be altered/removed once we find real use-cases
  def validate_agreement_item_combinations
    # if self.payment_agreement.general_invoices.present? and self.payment_agreement.rental_invoices.present?
    #   add_message :error, 'Both general and rental cannot be a part of same agreement'
    #   return
    # end

    # if self.payment_agreement.security_deposits.present? and self.payment_agreement.beneficiary_payments.present?
    #   add_message :error, 'Security deposit and beneficiary payment cannot be a part of same agreement'
    #   return
    # end
  end


  # Handle this since frontend is failing and need for demo
  def set_selected_invoice_frequency_attributes(invoice)
    return unless invoice.billing_type.fixed_periodic?
    frequency = self.payment_agreement.selected_invoice_frequency_attributes
    if frequency.present?
      invoice_frequency_value = frequency[:invoice_frequency_value]
      period_id = Period.id_for(:month)
      if invoice_frequency_value.present? && period_id.present?
        # invoice.create_invoice_frequency(number:invoice_frequency_value, period_id: period_id)
        new_invoice_frequency = InvoiceFrequency.create(number: invoice_frequency_value, period_id: period_id)
        invoice.update(invoice_frequency_id: new_invoice_frequency.id)
        return invoice.reload
      end
    end
    nil
  end

  # For fixed periodic, prepaid yes/no should be same of all invoices
  def validate_prepaid_consistency
    if self.payment_agreement.general_invoices.fixed_periodic_type.present?
      if self.payment_agreement.general_invoices.fixed_periodic_type.pluck(:prepaid).uniq.count > 1
        add_message :error, "All general invoices should be either prepaid or postpaid"
        return
      end
    end
    if self.payment_agreement.rental_invoices.fixed_periodic_type.present?
      if self.payment_agreement.rental_invoices.fixed_periodic_type.pluck(:prepaid).uniq.count > 1
        add_message :error, "All rental invoices should be either prepaid or postpaid"
        return
      end
    end
  end

  def create_invoice_template
    
  end

  # Every group of vendor should have same start date and end date
  def validate_grouped_vendor_start_end_date
    if self.payment_agreement.general_invoices.fixed_periodic_type.present? && self.payment_agreement.general_invoices.fixed_periodic_type.count > 1
      validate_gi_vendor_start_end_date
    end
    if self.payment_agreement.rental_invoices.fixed_periodic_type.present? && self.payment_agreement.rental_invoices.fixed_periodic_type.count > 1
      validate_ri_vendor_start_end_date
    end
  end


  # If any group of vendor are present in an invoice, same group of vendor should be present in eveny invoice
  # If escalation is for one vendor, escalation should be for every vendor
  def validate_gi_vendor_start_end_date
    validate_invoice_vendor_start_end_date('general_invoice')
    # vendor_ids = self.payment_agreement.general_invoices.fixed_periodic_type.pluck(:vendor_id).uniq
    # vendor_ids.each do |vendor_id|
    #   return if has_errors?
    #   self.payment_agreement.general_invoices.fixed_periodic_type.where(vendor_id: vendor_id).each do |general_invoice|
    #     start_date, end_date = general_invoice.start_date, general_invoice.end_date
    #     # Start date and end date present for one vendor should be present for other other vendors too(same start and end date for group of vendors)
    #     other_vendor_ids = vendor_ids - [vendor_id]
    #     other_vendor_ids.each do |other_vendor_id|
    #       if self.payment_agreement.general_invoices.fixed_periodic_type.where(vendor_id: other_vendor_id, start_date: start_date, end_date: end_date).blank?
    #         add_message :error, "Vendor #{YesBankVendor.find(other_vendor_id).display_name} start date(#{start_date}) and end date(#{end_date}) should match with other vendors or vice versa."
    #         add_message :error, "Vendor #{YesBankVendor.find(vendor_id).display_name} start date(#{start_date}) and end date should match with that of #{YesBankVendor.find(other_vendor_id).display_name} start date or vice versa"
    #         return
    #       end 
    #     end
    #   end
    # end
  end

  def validate_ri_vendor_start_end_date
    validate_invoice_vendor_start_end_date('rental_invoice')
  end

  def validate_invoice_vendor_start_end_date(invoice_type)
    vendor_ids = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.pluck(:vendor_id).uniq
    vendor_ids.each do |vendor_id|
      return if has_errors?
      self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).each do |invoice|
        start_date, end_date = invoice.start_date, invoice.end_date
        # Start date and end date present for one vendor should be present for other other vendors too(same start and end date for group of vendors)
        other_vendor_ids = vendor_ids - [vendor_id]
        other_vendor_ids.each do |other_vendor_id|
          if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: other_vendor_id, start_date: start_date, end_date: end_date).blank?
            add_message :error, "Vendor #{YesBankVendor.find(other_vendor_id).display_name} start date(#{start_date}) and end date(#{end_date}) should match with other vendors or vice versa."
            add_message :error, "Vendor #{YesBankVendor.find(vendor_id).display_name} start date(#{start_date}) and end date should match with that of #{YesBankVendor.find(other_vendor_id).display_name} start date or vice versa"
            return
          end 
        end
      end
    end
  end

  # Return are immediate so that page does not get bombarded with tons of errors
  def validate_all_dates(dates)
    dates.each do |date|
      return if has_errors?
      start_date, end_date = date[0].to_date, date[1].to_date
      if start_date < payment_agreement.execution_date.to_date
        add_message :error, "Start Date: #{start_date} cannot be less than agreement execution date: #{self.payment_agreement.execution_date.to_date}"
      end

      unless payment_agreement.no_expiration
        if start_date > payment_agreement.expiration_date.to_date
          add_message :error, "Start Date: #{start_date} cannot be more than agreement expiration date"
        end
        if end_date > payment_agreement.expiration_date.to_date
          add_message :error, "End Date: #{end_date} cannot be more than agreement expiration date"
        end
      end

      if end_date < payment_agreement.execution_date.to_date
        add_message :error, "End Date: #{end_date} cannot be less than agreement execution date"
      end
      if start_date >= end_date
        add_message :error, "Start date: #{start_date} cannot be greater than or equal to end date: #{end_date}"
      end
      if end_date <= start_date
        add_message :error, "End date: #{end_date} cannot be smaller than or equal to start date: #{start_date}"
      end
    end
  end

  def get_invoice_frequency(invoice_type)
    # self.payment_agreement&.selected_invoice_frequency_attributes["invoice_frequency_value"]&.to_i # TODO = Temp setup - REMOVE IT
    if self.payment_agreement&.selected_invoice_frequency_attributes.present? && self.payment_agreement&.selected_invoice_frequency_attributes["invoice_frequency_value"].present?
      return self.payment_agreement&.selected_invoice_frequency_attributes["invoice_frequency_value"]&.to_i
    end
    if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.first.invoice_frequency.present? 
      return self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.first.invoice_frequency.number
    end
  end

  def validate_start_date_as_start_of_month(start_date, dates=nil, index=nil)
    unless index == 1
      previous_date = dates[index-2] # 2 as index is starting from 1
      previous_start_date = previous_date[0]&.to_date
      previous_end_date = previous_date[1]&.to_date
      if (start_date >= previous_start_date && start_date <= previous_end_date)
        add_message :error, "Start Date: #{start_date} cannot come in between #{previous_start_date} and #{previous_end_date}"
        return false
      end
    end
    start_date == start_date.beginning_of_month
  end

  def validate_end_date_as_end_of_month(end_date,last_end_date=nil)
    return true if last_end_date
    end_date == end_date.end_of_month
  end

  def fixed_periodic_grouped_vendor_validations
    validate_grouped_vendor_start_end_date unless has_errors?
  end

  def security_deposit_validation
    if self.payment_agreement.security_deposits.count > 1
      unless self.payment_agreement.security_deposits.pluck(:vendor_id).count == self.payment_agreement.security_deposits.pluck(:vendor_id).uniq.count
        add_message :error, "All security deposits should have different vendors"
      end
    end
  end

  def validate_start_date_and_execution_date(invoice_type)
    group_vendor_count_by_id = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.group(:id).count
    # Do not run this validation for single fixed periodic with multiple vendors
    if group_vendor_count_by_id.values.uniq.count == 1 && group_vendor_count_by_id.values.uniq.include?(1)
      return
    end
    execution_date = self.payment_agreement.execution_date.to_date
    vendor_ids = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.pluck(:vendor_id).uniq
    unless self.payment_agreement.send(invoice_type.pluralize.to_sym).where(vendor_id: vendor_ids).fixed_periodic_type.where(start_date: execution_date).count == vendor_ids.count
      add_message :error, "#{vendor_ids.count} vendors should have #{vendor_ids.count} #{invoice_type.pluralize} with start date equal to execution date: #{execution_date}"
    end
  end

  def validate_end_date_end_expiration_date(invoice_type)
    group_vendor_count_by_id = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.group(:id).count
    # Do not run this validation for single fixed periodic with multiple vendors
    if group_vendor_count_by_id.values.uniq.count == 1 && group_vendor_count_by_id.values.uniq.include?(1)
      return
    end
    unless self.payment_agreement.no_expiration
      expiration_date = self.payment_agreement.expiration_date.to_date
      vendor_ids = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.pluck(:vendor_id).uniq
      unless self.payment_agreement.send(invoice_type.pluralize.to_sym).where(vendor_id: vendor_ids).fixed_periodic_type.where(end_date: expiration_date).count == vendor_ids.count
        add_message :error, "#{vendor_ids.count} vendors should have #{vendor_ids.count} #{invoice_type.pluralize} with end date equal to expiration date: #{expiration_date}"
      end
    end
  end


  # Jugaad as frontend calculations get messed up if quantity is set to zero for mutiple invoice in payment agreement
  def validate_item_quantity
    if self.payment_agreement.general_invoices.present?
      validate_invoice_item_quantity('general_invoice')
    end
    if self.payment_agreement.rental_invoices.present?
      validate_invoice_item_quantity('rental_invoice')
    end
  end

  def validate_invoice_item_quantity(invoice_type)
    self.payment_agreement.send(invoice_type.pluralize.to_sym).each do |invoice|
      if invoice.invoice_items.present?
        invoice.invoice_items.each do |invoice_line_item|
          set_discount_in_item(invoice_line_item)
          if invoice_line_item.quantity == 0
            add_message :error, "Quantity for #{invoice_line_item&.description} cannot be zero"
            return
          end
        end
      end
    end
  end

  def set_discount_in_item(invoice_line_item)
    value = invoice_line_item&.discount_amount&.value
    invoice_line_item.discount = value if invoice_line_item.discount.blank?
    if value.blank?
      invoice_line_item&.discount_amount&.value = 0.0
      invoice_line_item&.discount_amount&.currency_id = 1
    end
  end

  # TODO - REMOVE THIS - custom field is not saving on calling save on parent 
  # 
  def save_custom_fields
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.each do |general_invoice|
        if general_invoice.custom_fields.present?
          general_invoice.custom_fields.each do |custom_field|
            custom_field.save
          end
        end
      end
    end

    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.each do |rental_invoice|
        if rental_invoice.custom_fields.present?
          rental_invoice.custom_fields.each do |custom_field|
            custom_field.save
          end
        end
      end
    end
  end

  def update_total_invoice_amount(invoice)
    if invoice.billing_type.variable_periodic?
      if invoice.available_invoice_amount.blank?
        invoice.available_invoice_amount = invoice.total_invoice_amount.dup
        invoice.save
      else
        invoice.available_invoice_amount.update(value: invoice.total_invoice_amount&.value)
      end
    end
  end

  def update_invoice_limit(invoice)
      if invoice.total_invoice_amount.value.blank?# || invoice.billing_type.one_time? || invoice.billing_type.fixed_periodic?
        invoice.total_invoice_amount = nil
        invoice.available_invoice_amount = nil
      end
    if invoice.billing_type.variable_periodic?
      if invoice.total_invoice_amount.blank? || invoice&.total_invoice_amount&.value.blank?
        add_message :error, "Maximum invoice amount cannot be blank"
        return
      end

    end
  end

end