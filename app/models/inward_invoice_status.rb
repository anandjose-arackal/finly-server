# == Schema Information
#
# Table name: inward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InwardInvoiceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed]
  end

  def unpaid?
    self.id == InwardInvoiceStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == InwardInvoiceStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == InwardInvoiceStatus.id_for(:paid)
  end

  def open?
    self.id == InwardInvoiceStatus.id_for(:open)
  end

  def processing?
    self.id == InwardInvoiceStatus.id_for(:processing)
  end

  def approved?
    self.id == InwardInvoiceStatus.id_for(:approved)
  end

  def rejected?
    self.id == InwardInvoiceStatus.id_for(:rejected)
  end

  def auto_approved?
    self.id == InwardInvoiceStatus.id_for(:auto_approved)
  end

  def closed?
    self.id == InwardInvoiceStatus.id_for(:closed)
  end

  def retracted?
    self.id == InwardInvoiceStatus.id_for(:retracted)
  end

end
