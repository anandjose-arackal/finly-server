# == Schema Information
#
# Table name: inward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class InwardInvoiceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated]
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

  def pending?
    self.id == InwardInvoiceStatus.id_for(:pending)
  end

  def initiated?
    self.id == InwardInvoiceStatus.id_for(:initiated)
  end


  # this will encapsulate all IDs of an invoice that come under the committed bucket of a budget
  def self.ids_for_committed_bucket
    [
        InwardInvoiceStatus.id_for(:open),
        InwardInvoiceStatus.id_for(:retracted),
        InwardInvoiceStatus.id_for(:processing)
    ]
  end

  def self.ids_for_pending_payment_bucket
    [
        InwardInvoiceStatus.id_for(:approved),
        InwardInvoiceStatus.id_for(:auto_approved),
        InwardInvoiceStatus.id_for(:initiated),
        InwardInvoiceStatus.id_for(:unpaid)
    ]
  end

end
