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
      debugger
      # assign the respective calculated parameters to the payment params
      params[:invoice_attributes][:invoice_items_attributes][index][:amount_attributes] = {
          value: self.invoice_item_amount,
          currency_id: 1,
          id: item.amount&.id
      }
      params[:invoice_attributes][:invoice_items_attributes][index][:tax_amount_attributes] = {
          value: self.tax_amount,
          currency_id: 1,
          id: item.tax_amount&.id
      }
      params[:invoice_attributes][:invoice_items_attributes][index][:discount_amount_attributes] = {
          value: self.discount_amount,
          currency_id: 1,
          id: item.discount_amount&.id
      }
      params[:invoice_attributes][:invoice_items_attributes][index][:net_amount_attributes] = {
          value: self.net_amount,
          currency_id: 1,
          id: item.net_amount&.id
      }
    end
    params[:invoice_attributes][:amount_attributes] = {
        value: self.invoice_total,
        currency_id: 1,
        id: invoice.amount&.id
    }

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