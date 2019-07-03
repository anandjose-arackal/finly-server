class PaymentAgreements::Base < BaseOperation

  attr_accessor :company, :workflow_output, :payment_agreement


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters, try again'
      return
    end
  end

  def payment_agreement_parameters
    params.require(:payment_agreement).permit(

      :id, :title, :policy_id, :agreement_date, :execution_date, :expiration_date, :renewal_date, :note, :no_expiration, :renewal_reminder_date , :reject_note, 

      general_invoices_attributes: [:id, :_destroy, :department_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :bank_account_id, :note, :billing_start_date, :billing_day_of_month, :discount_type_id, :tds_slab_id, :roundoff_amount, :vendor_id, :vendor_location_id,

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
        extra_charges_attributes: [:id, :currency_id, :value],
        notify_users_attributes: [:id, :_destroy, :user_id],
        payment_agreement_escalation_attributes: [:id, :period_id, :number, :percentage_increment],
        invoice_frequency_attributes: [:id, :number, :period_id]
      ],
      rental_invoices_attributes: [:id, :_destroy, :department_id, :bank_account_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :note, :vendor_id, :vendor_location_id, :billing_start_date, :billing_day_of_month, :tds_slab_id, :discount_type_id, :roundoff_amount,

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
        payment_agreement_escalation_attributes: [:id, :period_id, :number, :percentage_increment],
        invoice_frequency_attributes: [:id, :number, :period_id]
      ],
      beneficiary_payments_attributes: [:id, :_destroy, :vendor_id, :bank_account_id, :cost_center_id, :department_id, :location_id, :note, :vendor_location_id, :tax, :inclusive_of_taxes, :gst_type_id, :tds_slab_id, :renewal_date, :tax_rate_id, 
        tax_amount_attributes: [:id, :value, :currency_id],
        payable_amount_attributes: [:id, :currency_id, :value],
        original_amount_attributes: [:id, :currency_id, :value]

      ],
      security_deposits_attributes: [:id, :_destroy, :vendor_id, :note, :cost_center_id, :department_id, :location_id, :vendor_location_id, :bank_account_id, 
        original_amount_attributes: [:id, :currency_id, :value]
      ]
      
      )
  end

  private

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
        update_balance_due_amount(general_invoice, general_invoice.net_amount.value)
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
        update_balance_due_amount(rental_invoice, rental_invoice.net_amount.value)
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
        due_date = billing_start_date
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


end