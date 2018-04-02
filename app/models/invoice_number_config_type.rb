class InvoiceNumberConfigType < ActiveRecord::Base

  include Seedable

  def self.values
    [
        :tax_invoice,
        :advance,
        :credit_note,
        :debit_note
    ]
  end
end
