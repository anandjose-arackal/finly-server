# == Schema Information
#
# Table name: outward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OutwardInvoiceStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:unpaid, :saved, :partially_paid, :closed, :cancelled, :sent_to_customer, :incomplete]
  end

  def unpaid?
    self.id == OutwardInvoiceStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == OutwardInvoiceStatus.id_for(:partially_paid)
  end

  def closed?
    self.id == OutwardInvoiceStatus.id_for(:closed)
  end

  def incomplete?
    self.id == OutwardInvoiceStatus.id_for(:incomplete)
  end

  def saved?
    self.id == OutwardInvoiceStatus.id_for(:saved)
  end

  def sent_to_customer?
    self.id == OutwardInvoiceStatus.id_for(:sent_to_customer)
  end

  def cancelled?
    self.id == OutwardInvoiceStatus.id_for(:cancelled)
  end
end