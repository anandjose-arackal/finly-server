# == Schema Information
#
# Table name: inward_invoice_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InwardInvoiceType < ApplicationRecord

  include Seedable

  def self.values
    [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice, :general_invoice]
  end

  def tax_invoice?
    self.id == InwardInvoiceType.id_for(:tax_invoice)
  end

  def advance?
    self.id == InwardInvoiceType.id_for(:advance)
  end

  def non_po_invoice?
    self.id == InwardInvoiceType.id_for(:non_po_invoice)
  end

  def beneficiary?
    self.id == InwardInvoiceType.id_for(:beneficiary)
  end

  def proforma_invoice?
    self.id == InwardInvoiceType.id_for(:proforma_invoice)
  end

  def general_invoice
    self.id == InwardInvoiceType.id_for(:general_invoice)
  end

end