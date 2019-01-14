# == Schema Information
#
# Table name: outward_invoice_types
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class OutwardInvoiceType < ApplicationRecord

  validates :name, presence: true

  include Seedable

  def self.values
    [:tax_invoice, :advance, :credit_note, :debit_note]
  end

  def tax_invoice?
    self.id == OutwardInvoiceType.id_for(:tax_invoice)
  end

  def advance_invoice?
    self.id == OutwardInvoiceType.id_for(:advance)
  end

  def credit_note?
    self.id == OutwardInvoiceType.id_for(:credit_note)
  end

  def debit_note?
    self.id == OutwardInvoiceType.id_for(:debit_note)
  end

end
