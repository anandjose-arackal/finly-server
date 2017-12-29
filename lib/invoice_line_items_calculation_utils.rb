# this class will handle all calculations regarding invoice items
class InvoiceLineItemsCalculationUtils

  attr_accessor :invoice_item_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tax_amount, :after_tax_amount,
                :invoice_total

  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the params object for direct assign
  def calculate_tax_and_discounts(params, payment = nil, invoice = nil)
    invoice = invoice || payment&.invoice
    if invoice.blank?
      return
    end
    self.invoice_total = 0
    invoice.invoice_items.each_with_index do |item, index|
      # calculate proactively
      self.invoice_item_amount = item.quantity * item.rate
      calculate_discount_exclusive(item)
      calculate_exclusive_taxes(item)
      self.net_amount = self.gross_amount + self.tax_amount
      self.invoice_total += self.net_amount
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
    end

    # assign invoice amount
    if invoice.amount.present?
      invoice.amount.value = self.invoice_total
    else
      invoice.amount = Amount.new(value: self.invoice_total, currency_id: 1)
    end

    # now calculate the TDS and the advance amount of this particular invoice, and return the store the new payment params here
    InvoiceCalculationUtils.new.calculate_tds_and_advance(params, self.invoice_total, payment)
    params
  end

  def calculate_discount_exclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_item_amount
      return
    end
    # because the discount rate will always be known
    self.discount_amount = (item.discount * self.invoice_item_amount)/100
    self.gross_amount = self.invoice_item_amount - self.discount_amount
  end

  def calculate_discount_inclusive(item)
    if item.discount.blank?
      self.discount_amount = 0
      self.invoice_item_amount = self.gross_amount
      return
    end
    # because the discount is also always shown
    self.invoice_item_amount = (self.gross_amount*100)/(100 - item.discount)
    self.discount_amount = self.invoice_item_amount - self.gross_amount
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
      self.after_tax_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_tax_amount, (item.tax))
    self.tax_amount = self.after_tax_amount - self.gross_amount
  end


end