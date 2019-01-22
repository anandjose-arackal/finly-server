# == Schema Information
#
# Table name: outward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OutwardInvoiceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:saved, :partially_paid, :paid, :cancelled, :incomplete]
  end

  def partially_paid?
    self.id == OutwardInvoiceStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == OutwardInvoiceStatus.id_for(:paid)
  end

  def unpaid?
    self.id == OutwardInvoiceStatus.id_for(:unpaid)
  end

  def incomplete?
    self.id == OutwardInvoiceStatus.id_for(:incomplete)
  end

  def saved?
    self.id == OutwardInvoiceStatus.id_for(:saved)
  end

  def cancelled?
    self.id == OutwardInvoiceStatus.id_for(:cancelled)
  end

  def status_name
    self.name
  end
end