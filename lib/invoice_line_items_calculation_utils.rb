# this class will handle all calculations regarding invoice items
class InvoiceLineItemsCalculationUtils

  include MathUtil

  attr_accessor :invoice_item_amount, :payment_amount, :after_discount_amount,
                :gross_amount, :net_amount, :invoice, :item_taxable_amount, :taxable_amount,
                :discount_amount, :tax_amount, :after_tax_amount, :tds_applicable_amount,
                :invoice_total, :roundoff_amount, :total_discount, :total_tax, :payment_amount,
                :invoice_is_a_tax_invoice, :taxable_amount_for_service, :service_item

  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the params object for direct assign
  def calculate_tax_and_discounts(params, payment = nil, invoice = nil, payment_amount = nil)
    invoice = invoice || payment&.invoice
    if invoice.blank?
      return
    end
    self.invoice_is_a_tax_invoice = (invoice.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice))
    self.invoice_total = self.total_discount = self.total_tax = self.taxable_amount = self.tds_applicable_amount = self.taxable_amount_for_service = 0
    invoice.invoice_items.each_with_index do |item, index|
      self.service_item = ( (item.inventory_line_item.product_type_id == ProductType.id_for(:service)) && self.invoice_is_a_tax_invoice && invoice.company.feature_subscription.srn_enabled) rescue false
      self.item_taxable_amount = 0
      self.gross_amount = 0
      if invoice.inclusive_of_taxes # calculate the other amounts retrospectively
        # self.after_tax_amount = item.quantity * item.rate
        self.invoice_item_amount = item.quantity * item.rate
        # first calculate the net amount to be paid after discount
        calculate_discount_inclusive(item)
        calculate_inclusive_taxes(item)
        self.item_taxable_amount += self.gross_amount
        # if the item is TDS deductible, add it to the tax applicable amount
        if item.tds_applicable? && invoice.tds_slab_id.present?
          self.tds_applicable_amount += self.gross_amount
        end
        # self.invoice_item_amount = self.gross_amount + self.discount_amount
        self.net_amount = self.invoice_item_amount - self.discount_amount
      else # calculate proactively
        self.invoice_item_amount = item.quantity.to_f * item.rate.to_f
        calculate_discount_exclusive(item)
        calculate_billable_amount(item) # this is mainly if item is a service
        calculate_exclusive_taxes(item)
        self.item_taxable_amount += self.gross_amount
        if invoice.rcm_enabled?
          self.net_amount = self.gross_amount
        else
          self.net_amount = self.gross_amount + self.tax_amount
        end
      end
      self.invoice_total += self.net_amount
      total_invoice_discount = (self.service_item) ? 0 : self.discount_amount
      self.total_discount += total_invoice_discount
      self.total_tax += self.tax_amount
      self.taxable_amount += self.item_taxable_amount
      if item.tds_applicable? && invoice.tds_slab_id.present?
        self.tds_applicable_amount += self.item_taxable_amount
      end
      # assign the respective calculated parameters to the payment params
      # invoice line item raw amount
      if item.amount.present?
        item.amount.value = self.invoice_item_amount
        item.amount.currency_id = Currency.first.id
      else
        item.amount = Amount.new(value: self.invoice_item_amount, currency_id: 1)
      end

      # invoice item tax amount
      if item.tax_amount.present?
        item.tax_amount.value = self.tax_amount.abs
        item.tax_amount.currency_id = Currency.first.id
      else
        item.tax_amount = Amount.new(value: self.tax_amount.abs, currency_id: 1)
      end

      # invoice discount amount
      if item.discount_amount.present?
        item.discount_amount.value = self.discount_amount
        item.discount_amount.currency_id = Currency.first.id
      else
        item.discount_amount = Amount.new(value: self.discount_amount, currency_id: 1)
      end

      # invoice item net amount
      if item.net_amount.present?
        item.net_amount.value = self.net_amount.abs
        item.net_amount.currency_id = Currency.first.id
      else
        item.net_amount = Amount.new(value: self.net_amount.abs, currency_id: 1)
      end

      # invoice item taxable amount
      if item.taxable_amount.present?
        taxable_amount_value = (self.service_item) ? self.taxable_amount_for_service : self.item_taxable_amount
        # item.taxable_amount.value = self.item_taxable_amount
        item.taxable_amount.value = taxable_amount_value.abs
        item.taxable_amount.currency_id = Currency.first.id
      else
        taxable_amount_value = (self.service_item) ? self.taxable_amount_for_service : self.item_taxable_amount
        # item.taxable_amount = Amount.new(value: self.item_taxable_amount, currency_id: 1)
        item.taxable_amount = Amount.new(value: taxable_amount_value.abs, currency_id: 1)
      end
    end

    # assign invoice amount
    if invoice.amount.present?
      invoice.amount.value = self.invoice_total
    else
      invoice.amount = Amount.new(value: self.invoice_total, currency_id: 1)
    end

    # assign invoice tax amount - which is a summation of all taxes of all invoice items
    if invoice.tax_amount.present?
      invoice.tax_amount.value = self.total_tax
    else
      invoice.tax_amount = Amount.new(value: self.total_tax, currency_id: 1)
    end

    # assign invoice discount amount - which is a summation of all discounts of all invoice items
    if invoice.discount_amount.present?
      invoice.discount_amount.value = self.total_discount
    else
      invoice.discount_amount = Amount.new(value: self.total_discount, currency_id: 1)
    end

    # now calculate the TDS and the advance amount of this particular invoice, and return the store the new payment params here
    InvoiceCalculationUtils.new.calculate_tds_and_advance(params, self.taxable_amount, self.invoice_total, self.tds_applicable_amount, payment, invoice, payment_amount)
    InvoiceCalculationUtils.new.calculate_cn_adjustments(params, payment, invoice)
    params
  end

  def calculate_discount_exclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_item_amount
      return
    end
    # depending on the type of discount being sent
    if item.parent.is_a?(OutwardInvoice)
      self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
    else
      case item.parent.discount_type_id
        # i.e. discount is given as a rate
        when 1
          self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
        when 2
          # self.discount_amount = item.discount.to_f
          po_item = item.purchase_order_item
          if po_item.present?
            po_item_amount = po_item.rate.to_f * po_item.quantity.to_f
          end
          item_amount = po_item.present? ? po_item_amount : self.invoice_item_amount
          rate = ((item.discount.to_f / item_amount) * 100).round(2) rescue 0
          self.discount_amount = (rate.to_f * self.invoice_item_amount.to_f) / 100
        else
          self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
      end
    end
    self.gross_amount = self.invoice_item_amount - self.discount_amount
  end

  def calculate_discount_inclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.after_discount_amount = self.invoice_item_amount
      return
    end
    # depending on the type of discount being sent
    case item.parent.discount_type_id
      # i.e. discount is given as a rate
      when 1
        self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
      when 2
        # self.discount_amount = item.discount.to_f
        rate = ((item.discount.to_f / self.invoice_item_amount) * 100).round(2) rescue 0
        self.discount_amount = (rate.to_f * self.invoice_item_amount.to_f) / 100
      else
        self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
    end
    self.after_discount_amount = self.invoice_item_amount - self.discount_amount
  end

  def calculate_exclusive_taxes(item)
    if item.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      item.igst = 0
      item.cgst = 0
      item.sgst = 0
      return
    end
    if item.parent.class.name == 'OutwardInvoice'
      self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (item.tax))
      self.tax_amount = self.net_amount - self.gross_amount
    else
      if item.parent&.rcm_enabled?
        self.net_amount = self.gross_amount
        # if RCM doesn't apply, we shall have to calculate the tax using a "pseudo" net amount
        # i.e. calculate tax as though RCM wasn't there and then tabulate it differently
        net_if_tax_applied = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (item.tax_rate&.rate))
        self.tax_amount = net_if_tax_applied - self.gross_amount
      else
        self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (item.tax_rate&.rate))
        self.tax_amount = self.net_amount - self.gross_amount
      end
    end
    # setting the SGST, CGST and IGST values for the invoice
    case item.parent.gst_type_id
      when GstType.id_for(:cgst_sgst)
        item.cgst = self.tax_amount / 2
        item.sgst = self.tax_amount / 2
        item.igst = 0
      when GstType.id_for(:igst)
        item.igst = self.tax_amount
        item.cgst = 0
        item.sgst = 0
      else
        item.igst = 0
        item.cgst = 0
        item.sgst = 0
    end
  end

  def calculate_inclusive_taxes(item)
    if item.tax.blank?
      self.gross_amount = self.after_discount_amount
      self.tax_amount = 0
      item.igst = 0
      item.cgst = 0
      item.sgst = 0
      return
    end
    if item.parent.class.name == 'OutwardInvoice'
      self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_discount_amount, (item.tax))
    else
      self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_discount_amount, (item.tax_rate&.rate))
    end
    self.tax_amount = self.after_discount_amount - self.gross_amount
    # setting the SGST, CGST and IGST values for the invoice
    case item.parent.gst_type_id
      when GstType.id_for(:cgst_sgst)
        item.cgst = self.tax_amount / 2
        item.sgst = self.tax_amount / 2
        item.igst = 0
      when GstType.id_for(:igst)
        item.igst = self.tax_amount
        item.cgst = 0
        item.sgst = 0
      else
        item.igst = 0
        item.cgst = 0
        item.sgst = 0
    end
  end

  def calculate_billable_amount(item)
    if self.service_item
      self.taxable_amount_for_service = self.gross_amount
      self.gross_amount = item.billable_amount.value
    else
      self.gross_amount = self.gross_amount # for goods, keep it unchanged for now      
    end
  end
end