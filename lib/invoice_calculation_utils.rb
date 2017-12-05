# the library that will be used for all tax calculations
class InvoiceCalculationUtils

  attr_accessor :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance, :advance_amount, :invoice_total

  # don't go by the name - this calculates the Freight paid as well
  def calculate_tds_and_advance(params, invoice_total, payment = nil, invoice = nil)
    self.invoice = invoice || payment&.invoice
    if self.invoice.blank?
      return
    end
    self.gross_amount = invoice_total
    calculate_tds
    self.net_amount = self.gross_amount - self.tds_amount
    calculate_advance_paid
    params[:invoice_attributes][:tds_amount_attributes] = {
        value: self.tds_amount,
        currency_id: 1,
        id: self.invoice.tds_amount&.id
    }
    params[:invoice_attributes][:advance_amount_attributes] = {
        value: self.advance_amount,
        currency_id: 1,
        id: self.invoice.advance_amount&.id
    }
    params[:invoice_attributes][:net_amount_attributes] = {
        value: self.net_amount,
        currency_id: 1,
        id: self.invoice.net_amount&.id
    }

    # now calculating the final amount to be paid
    # adding the payment amount to the params if the payment was passed
    if payment.present?
      params[:amount_attributes] = {
          value: self.net_amount,
          currency_id: 1,
          id: payment.amount&.id
      }
    end
    params
  end


  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the params object for direct assign
  def calculate_tax_and_discounts(params, payment = nil, invoice = nil)
    self.invoice = invoice || payment&.invoice
    if self.invoice.blank?
      return
    end
    if self.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
      self.after_tax_amount = self.invoice.original_amount&.value
      # first calculate the gross amount from the
      calculate_inclusive_taxes
      calculate_tds
      calculate_discount_inclusive
      self.net_amount = self.after_tax_amount - self.tds_amount
      self.invoice_amount = self.gross_amount + self.discount_amount
      calculate_advance_paid
    else # calculate proactively
      self.invoice_amount = invoice.original_amount&.value
      calculate_discount_exclusive
      calculate_exclusive_taxes
      calculate_tds
      self.net_amount = self.gross_amount + self.tax_amount - self.tds_amount
      self.invoice_amount = invoice.original_amount&.value
      calculate_advance_paid
    end
    # assign the respective calculated parameters to the payment params
    params[:invoice_attributes][:amount_attributes] = {
        value: self.invoice_amount,
        currency_id: 1,
        id: self.invoice&.amount&.id
    }
    params[:invoice_attributes][:net_amount_attributes] = {
        value: self.net_amount,
        currency_id: 1,
        id: self.invoice&.net_amount&.id
    }
    params[:invoice_attributes][:gross_amount_attributes] = {
        value: self.gross_amount,
        currency_id: 1,
        id: self.invoice.gross_amount&.id
    }
    params[:invoice_attributes][:discount_amount_attributes] = {
        value: self.discount_amount,
        currency_id: 1,
        id: self.invoice.discount_amount&.id
    }
    params[:invoice_attributes][:tds_amount_attributes] = {
        value: self.tds_amount,
        currency_id: 1,
        id: self.invoice.tds_amount&.id
    }
    params[:invoice_attributes][:tax_amount_attributes] = {
        value: self.tax_amount,
        currency_id: 1,
        id: self.invoice.tax_amount&.id
    }
    params[:invoice_attributes][:advance_amount_attributes] = {
        value: self.advance_amount,
        currency_id: 1,
        id: self.invoice.advance_amount&.id
    }

    # adding the payment amount to the params if  the object is present
    if payment.present?
      params[:amount_attributes] = {
          value: self.net_amount,
          currency_id: 1,
          id: self.payment.amount&.id
      }
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
      self.invoice_amount = self.gross_amount
      return
    end
    # because the discount is also always shown
    self.invoice_amount = (self.gross_amount*100)/(100 - invoice.discount)
    self.discount_amount = self.invoice_amount - self.gross_amount
  end

  def calculate_exclusive_taxes
    if self.invoice.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax))
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes
    if self.invoice.tax.blank?
      self.after_tax_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_tax_amount, (self.invoice.tax))
    self.tax_amount = self.after_tax_amount - self.gross_amount
  end

  def calculate_tds
    new_gross_amount = TaxCalculationUtils.tds_amount(self.gross_amount, self.invoice.tds)
    self.tds_amount = self.gross_amount - new_gross_amount
  end

  def calculate_advance_paid
    if self.invoice.advance.blank?
      # no change in net amount
      self.advance_amount = 0
      return
    end
    original_net_amount = self.net_amount
    self.advance_amount = (self.invoice.advance*self.net_amount)/100
    self.net_amount = original_net_amount - self.advance_amount
  end

end