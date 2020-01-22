# the library that will be used for all tax calculations
class InvoiceCalculationUtils

  include MathUtil

  attr_accessor :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_discount_amount,
                :advance, :advance_amount, :invoice_total, :freight_amount,
                :roundoff_amount, :balance_due_amount, :payment_amount, :tds_applicable_amount, :cn_adjustment_amount

  # don't go by the name - this calculates the Freight paid as well
  def calculate_tds_and_advance(params, taxable_amount, invoice_amount, tds_applicable_amount, payment = nil, invoice = nil, payment_amount = nil)
    self.invoice = invoice || payment&.invoice
    if self.invoice.blank?
      return
    end
    # here the gross amount will be the total of invoices minus the discount
    self.gross_amount = taxable_amount
    self.invoice_amount = invoice_amount
    self.tds_applicable_amount = tds_applicable_amount
    calculate_tds
    self.net_amount = self.invoice_amount - self.tds_amount
    calculate_advance_paid
    calculate_freight_charges
    self.roundoff_amount = self.invoice.roundoff_amount.to_f # even if it's nil, it gets converted to 0

    if self.roundoff_amount != 0
      self.balance_due_amount = precision_value (self.net_amount + self.roundoff_amount)
    else
      self.balance_due_amount = precision_value self.net_amount
    end

    self.balance_due_amount = self.balance_due_amount - self.advance_amount

    # If po invoice has po advance, then adjust the balance due
    unless self.invoice.class.name == 'OutwardInvoice'
      if self.invoice.po_advance.present? && self.invoice.po_adjusted_advance[:value].present? && self.invoice.advance_amount_required
        self.balance_due_amount = self.balance_due_amount - self.invoice.po_adjusted_advance.value unless ( self.invoice.po_adjusted_advance.value > self.balance_due_amount )
      end
    end

    # # Applying Credit Note
    # unless self.invoice.class.name == 'OutwardInvoice'
    #   if cn_adjustment_amount > 0
    #     if cn_adjustment_amount <= balance_due_amount
    #       self.balance_due_amount -= cn_adjustment_amount
    #     else
    #       invoice.credit_note_adjustment
    #       self.balance_due_amount = 0
    #     end
    #   end
    # end

    # assign gross amount
    unless self.invoice.class.name == 'OutwardInvoice'
      if self.invoice&.gross_amount.present?
        self.invoice.gross_amount.value = self.gross_amount
      else
        self.invoice&.gross_amount = Amount.new(value: self.gross_amount, currency_id: 1)
      end
    end

    unless self.invoice.class.name == 'OutwardInvoice'
      # assign taxable amount
      if self.invoice&.taxable_amount.present?
        self.invoice.taxable_amount.value = taxable_amount
      else
        self.invoice.taxable_amount = Amount.new(value: taxable_amount, currency_id: 1)
      end
    end

    # assign TDS and advance amount
    if self.invoice&.tds_amount.present?
      self.invoice.tds_amount.value = self.tds_amount
    else
      self.invoice.tds_amount = Amount.new(value: self.tds_amount, currency_id: 1)
    end

    if self.invoice&.advance_amount.present?
      self.invoice.advance_amount.value = self.advance_amount
    else
      self.invoice.advance_amount = Amount.new(value: self.advance_amount, currency_id: 1)
    end

    # assign net amount
    if self.invoice.net_amount.present?
      self.invoice.net_amount.value = self.net_amount
    else
      self.invoice.net_amount = Amount.new(value: self.net_amount, currency_id: 1)
    end


    # assign balance due
    if self.invoice.balance_due.present?
      self.invoice.balance_due.value = self.balance_due_amount
    else
      self.invoice.balance_due = Amount.new(value: self.balance_due_amount, currency_id: 1)
    end

    # set total payable if it's an outward invoice
    if self.invoice.is_a?(OutwardInvoice)
      if self.invoice.total_payable.present?
        self.invoice.total_payable.value = self.balance_due_amount
      else
        self.invoice.total_payable = Amount.new(value: self.balance_due_amount, currency_id: 1)
      end
    end

    # now calculating the final amount to be paid
    # assigning the final amount to the payment
    self.payment_amount = payment_amount || self.balance_due_amount
    # self.payment_amount = self.balance_due_amount
    if payment.present?
      if payment.amount.present?
        payment.amount.value = self.payment_amount.round(2)
      else
        payment.amount = Amount.new(value: self.payment_amount.round(2), currency_id: 1)
      end
    end
    params
  end


  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the invoice object that is passed
  def calculate_tax_and_discounts(params, payment = nil, invoice = nil, payment_amount = nil)
    self.invoice = invoice || payment&.invoice
    if self.invoice.blank?
      return
    end
    if self.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
      self.original_amount = self.invoice.original_amount&.value
      # first calculate the gross amount by deducting the discount from
      # the original amount entered
      calculate_discount_inclusive
      calculate_inclusive_taxes
      self.tds_applicable_amount = self.gross_amount
      calculate_tds
      self.net_amount = self.after_discount_amount - self.tds_amount
      self.invoice_amount = self.original_amount # todo - gotta check the ramifications of this
      calculate_advance_paid
      calculate_freight_charges
    else # calculate proactively
      self.invoice_amount = self.invoice.original_amount&.value
      calculate_discount_exclusive
      calculate_exclusive_taxes
      self.tds_applicable_amount = self.gross_amount
      calculate_tds
      self.net_amount = (self.gross_amount + self.tax_amount - self.tds_amount) rescue 0
      self.invoice_amount = self.invoice.original_amount&.value
      calculate_advance_paid
      calculate_freight_charges
    end
    self.roundoff_amount = self.invoice.roundoff_amount.to_f # even if it's nil, it gets converted to 0
    if self.roundoff_amount != 0
      self.balance_due_amount = precision_value (self.net_amount + self.roundoff_amount)
    else
      self.balance_due_amount = precision_value self.net_amount
    end

    self.balance_due_amount = self.balance_due_amount - self.advance_amount

    # assign the respective calculated amounts to the payment and invoice object

    # assign invoice amount
    if self.invoice.amount.present?
      self.invoice.amount.value = self.invoice_amount
    else
      self.invoice.amount = Amount.new(value: self.invoice_amount, currency_id: 1)
    end

    # assign gross amount
    if self.invoice.gross_amount.present?
      self.invoice.gross_amount.value = self.gross_amount
    else
      self.invoice.gross_amount = Amount.new(value: self.gross_amount, currency_id: 1)
    end

    # assign discount amount
    if self.invoice.discount_amount.present?
      self.invoice.discount_amount.value = self.discount_amount
    else
      self.invoice.discount_amount = Amount.new(value: self.discount_amount, currency_id: 1)
    end

    # assign tax amount
    if self.invoice.tax_amount.present?
      self.invoice.tax_amount.value = self.tax_amount
    else
      self.invoice.tax_amount = Amount.new(value: self.tax_amount, currency_id: 1)
    end

    # assign TDS amount
    if self.invoice&.tds_amount.present?
      self.invoice.tds_amount.value = self.tds_amount
    else
      self.invoice.tds_amount = Amount.new(value: self.tds_amount, currency_id: 1)
    end

    # assign advance amount
    if self.invoice&.advance_amount.present?
      self.invoice.advance_amount.value = self.advance_amount
    else
      self.invoice.advance_amount = Amount.new(value: self.advance_amount, currency_id: 1)
    end

    # assign net amount
    if self.invoice.net_amount.present?
      self.invoice.net_amount.value = self.net_amount
    else
      self.invoice.net_amount = Amount.new(value: self.net_amount, currency_id: 1)
    end

    # assign balance due
    if self.invoice.balance_due.present?
      self.invoice.balance_due.value = self.balance_due_amount
    else
      self.invoice.balance_due = Amount.new(value: self.balance_due_amount, currency_id: 1)
    end

    # adding the payment amount to the params if  the object is present
    self.payment_amount = payment_amount || self.balance_due_amount
    # self.payment_amount = self.balance_due_amount
    if payment.present?
      if payment.amount.present?
        payment.amount.value = self.payment_amount
      else
        payment.amount = Amount.new(value: self.payment_amount, currency_id: 1)
      end
    end
    params
  end


  def calculate_discount_exclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_amount
      return
    end
    # because the discount rate will always be known
    self.discount_amount = (invoice.discount*self.invoice_amount)/100
    self.gross_amount = self.invoice_amount - self.discount_amount
  end

  def calculate_discount_inclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.after_discount_amount = self.original_amount
      return
    end
    # because the discount is also always shown
    self.discount_amount = (invoice.discount * self.original_amount)/100
    self.after_discount_amount = self.original_amount - self.discount_amount
  end

  def calculate_exclusive_taxes
    if self.invoice.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    if self.invoice.rcm_enabled?
      self.net_amount = self.gross_amount
      net_if_tax_applied = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax))
      self.tax_amount = net_if_tax_applied - self.gross_amount
    else
      self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax))
      self.tax_amount = self.net_amount - self.gross_amount
    end
  end

  def calculate_inclusive_taxes
    if self.invoice.tax.blank?
      self.gross_amount = self.after_discount_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_discount_amount, (self.invoice.tax))
    self.tax_amount = self.after_discount_amount - self.gross_amount
  end

  def calculate_tds
    if invoice.tds_slab_id.present?
      tds = invoice.tds_slab&.tds
      invoice.tds = tds # setting the TDS for this invoice as well
    else
      if invoice.is_a?(Invoice)
        tds = 0
        invoice.tds = 0
      else
        tds = invoice.tds
      end
    end
    new_gross_amount = TaxCalculationUtils.tds_amount(self.tds_applicable_amount, tds)
    self.tds_amount = (self.tds_applicable_amount - new_gross_amount) rescue 0
  end

  def calculate_advance_paid
    if self.invoice.advance_amount.blank?
      # no change in net amount
      self.advance_amount = 0
      return
    end
    original_net_amount = self.net_amount
    self.advance_amount = self.invoice.advance_amount&.value.to_f
    # self.net_amount = original_net_amount - self.advance_amount # net amount should be without previously paid advance
  end

  def calculate_freight_charges
    if self.invoice.freight_amount.blank?
      # no change in net amount
      self.freight_amount = 0
      return
    end
    original_net_amount = self.net_amount
    self.freight_amount = self.invoice.freight_amount&.value.to_f
    self.net_amount = original_net_amount + self.freight_amount
  end

  # Credit Note Adjustments
  def calculate_cn_adjustments(invoice_params, payment, invoice, calculation_from_payment)
    self.invoice = invoice || payment&.invoice
    # return if (invoice_params[:credit_note_adjustments_attributes].blank? || !invoice_params[:credit_note_adjustments_attributes].is_a?(Array))
    return unless invoice.class.name == "Invoice"

    removed_cna_ids = []
    # Where credit note adjustments are removed from an invoice
    if invoice_params[:credit_note_adjustments_attributes].present?
      removed_cna_ids = invoice_params[:credit_note_adjustments_attributes].filter {|item| item[:_destroy]}.map {|item| item[:id]}.compact
    end

    # Where credit note adjustments
    cna_added_amount = self.invoice.credit_note_adjustments.where.not(id: removed_cna_ids).joins(:amount).sum(:value)
    cna_removed_amount = self.invoice.credit_note_adjustments.where(id: removed_cna_ids).joins(:amount).sum(:value)
    # adjustment_amount_to_subtract = invoice_params[:credit_note_adjustments_attributes].filter {|item| item[:id].blank?}.map {|item| item[:amount_attributes]&.dig(:value).to_f}.sum


    balance_due_amount = self.invoice.balance_due.value

    # if calculation_from_payment
    #   balance_due_amount = balance_due_amount - cna_added_amount + cna_removed_amount
    #
    #   if balance_due_amount < 0
    #     amount_to_deduct = balance_due_amount.abs
    #
    #     self.invoice.credit_note_adjustments.reorder("created_at desc").each do |cna|
    #       break if amount_to_deduct == 0
    #       if amount_to_deduct >= cna.amount.value
    #         amount_to_deduct -= cna.amount.value
    #         cna.destroy
    #       else
    #         cna.amount.update(value: (cna.amount.value - amount_to_deduct))
    #         amount_to_deduct = 0
    #       end
    #     end
    #   end
    #   cna_added_amount = self.invoice.credit_note_adjustments.where.not(id: removed_cna_ids).joins(:amount).sum(:value)
    #   cna_removed_amount = self.invoice.credit_note_adjustments.where(id: removed_cna_ids).joins(:amount).sum(:value)
    #
    #   balance_due_amount = self.invoice.balance_due.value
    # end
    #

    # For Debugging
    Rails.logger.fatal "**************************************************************************************************"
    Rails.logger.fatal "Invoice Balance Due - #{self.invoice.balance_due.value.to_f}"
    Rails.logger.fatal "Invoice Credit Note Adjustments - #{self.invoice.credit_note_adjustments.as_json.inspect}"
    Rails.logger.fatal "CNA Added Amount #{cna_added_amount} \n CNA Removed Amount #{cna_removed_amount}"
    Rails.logger.fatal "Balance Due Amount(#{balance_due_amount}) - CNA Added Amount(#{cna_added_amount}) + CNA Removed Amount(#{cna_removed_amount})"
    # End of Debugging
    Rails.logger.fatal "**************************************************************************************************"

    balance_due_amount = balance_due_amount - cna_added_amount + cna_removed_amount
    balance_due_amount = precision_value balance_due_amount

    if self.invoice.balance_due.present?
      self.invoice.balance_due.value = balance_due_amount
    end
  end
end