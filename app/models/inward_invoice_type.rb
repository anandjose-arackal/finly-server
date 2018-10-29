# == Schema Information
#
# Table name: inward_invoice_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InwardInvoiceType < ActiveRecord::Base

  include Seedable

  def self.values
    [:tax_invoice, :advance, :non_po_invoice]
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

end