# this class will handle all calculations regarding
class InvoiceLineItemsCalculationUtils

  attr_accessor :invoice_item_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tax_amount, :after_tax_amount

  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the params object for direct assign
  def self.calculate_tax_and_discounts(payment, payment_params)
    invoice = payment.invoice
    if invoice.blank?
      return
    end
    payment.invoice.invoice_items.each_with_index do |item, index|
      if invoice.inclusive_of_taxes # calculate the other amounts retrospectively
        self.after_tax_amount = item.quantity * item.rate
        # first calculate the gross amount from the =
        calculate_inclusive_taxes(item)
        calculate_discount_inclusive(item)
        self.invoice_item_amount = self.gross_amount + self.discount_amount
        self.net_amount = self.after_tax_amount
      else # calculate proactively
        self.invoice_item_amount = item.quantity * item.rate
        calculate_discount_exclusive(item)
        calculate_exclusive_taxes
        self.net_amount = self.gross_amount + self.tax_amount
      end
      # assign the respective calculated parameters to the payment params
      payment_params[:invoice_attributes][:invoice_items_attributes][index][:amount_attributes] = {
          value: self.invoice_item_amount,
          currency_id: 1,
          id: item.amount&.id
      }
      payment_params[:invoice_attributes][:invoice_items_attributes][index][:tax_amount_attributes] = {
          value: self.tax_amount,
          currency_id: 1,
          id: item.tax_amount&.id
      }
      payment_params[:invoice_attributes][:invoice_items_attributes][index][:discount_amount_attributes] = {
          value: self.discount_amount,
          currency_id: 1,
          id: item.discount_amount&.id
      }
      payment_params[:invoice_attributes][:invoice_items_attributes][index][:net_amount_attributes] = {
          value: self.net_amount,
          currency_id: 1,
          id: item.net_amount&.id
      }
    end
    payment_params
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