# this class will handle all calculations regarding invoice items
class InvoiceLineItemsCalculationUtils

  include MathUtil

  attr_accessor :invoice_item_amount, :payment_amount, :after_discount_amount,
                :gross_amount, :net_amount, :invoice, :item_taxable_amount, :taxable_amount,
                :discount_amount, :tax_amount, :after_tax_amount, :tds_applicable_amount,
                :invoice_total, :roundoff_amount, :total_discount, :total_tax, :payment_amount

  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the params object for direct assign
  def calculate_tax_and_discounts(params, payment = nil, invoice = nil, payment_amount = nil)
    invoice = invoice || payment&.invoice
    if invoice.blank?
      return
    end
    self.invoice_total = self.total_discount = self.total_tax = self.taxable_amount = self.tds_applicable_amount = 0
    invoice.invoice_items.each_with_index do |item, index|
      self.item_taxable_amount = 0
      if invoice.inclusive_of_taxes # calculate the other amounts retrospectively
        # self.after_tax_amount = item.quantity * item.rate
        self.invoice_item_amount = item.quantity * item.rate
        # first calculate the net amount to be paid after discount
        calculate_discount_inclusive(item)
        calculate_inclusive_taxes(item)
        self.item_taxable_amount += self.gross_amount
        # if the item is TDS deductible, add it to the tax applicable amount
        if item.tds_applicable?
          self.tds_applicable_amount += self.gross_amount
        end
        # self.invoice_item_amount = self.gross_amount + self.discount_amount
        self.net_amount = self.invoice_item_amount - self.discount_amount
      else # calculate proactively
        self.invoice_item_amount = item.quantity.to_f * item.rate.to_f
        calculate_discount_exclusive(item)
        calculate_exclusive_taxes(item)
        self.item_taxable_amount += self.gross_amount
        self.net_amount = self.gross_amount + self.tax_amount
      end
      self.invoice_total += self.net_amount
      self.total_discount += self.discount_amount
      self.total_tax += self.tax_amount
      self.taxable_amount += self.item_taxable_amount
      if item.tds_applicable?
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
        item.tax_amount.value = self.tax_amount
        item.tax_amount.currency_id = Currency.first.id
      else
        item.tax_amount = Amount.new(value: self.tax_amount, currency_id: 1)
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
        item.net_amount.value = self.net_amount
        item.net_amount.currency_id = Currency.first.id
      else
        item.net_amount = Amount.new(value: self.net_amount, currency_id: 1)
      end

      # invoice item taxable amount
      if item.taxable_amount.present?
        item.taxable_amount.value = self.item_taxable_amount
        item.net_amount.currency_id = Currency.first.id
      else
        item.taxable_amount = Amount.new(value: self.taxable_amount, currency_id: 1)
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
    params
  end

  def calculate_discount_exclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_item_amount
      return
    end
    # because the discount rate will always be known
    self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f)/100
    self.gross_amount = self.invoice_item_amount - self.discount_amount
  end

  def calculate_discount_inclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.after_discount_amount = self.invoice_item_amount
      return
    end
    # because the discount is also always shown
    self.discount_amount = (item.discount.to_f * self.invoice_item_amount.to_f) / 100
    self.after_discount_amount = self.invoice_item_amount - self.discount_amount
  end

  def calculate_exclusive_taxes(item)
    if item.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (item.tax))
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes(item)
    if item.tax.blank?
      self.gross_amount = self.after_discount_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_discount_amount, (item.tax))
    self.tax_amount = self.after_discount_amount - self.gross_amount
  end
end