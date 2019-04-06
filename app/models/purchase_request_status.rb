# == Schema Information
#
# Table name: purchase_request_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PurchaseRequestStatus < ApplicationRecord

  include Seedable

  def self.values
    [
        :draft,
        :awaiting_approval,
        :approved,
        :auto_approved,
        :retracted,
        :rejected,
        :closed,
        :order_initiated,
        :cancelled
    ]
  end

  def open?
    self.id == PurchaseRequestStatus.id_for(:open)
  end

  def retracted?
    self.id == PurchaseRequestStatus.id_for(:retracted)
  end

  def rejected?
    self.id == PurchaseRequestStatus.id_for(:rejected)
  end

  def processing?
    self.id == PurchaseRequestStatus.id_for(:processing)
  end

  def approved?
    self.id == PurchaseRequestStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == PurchaseRequestStatus.id_for(:auto_approved)
  end

  def order_initiated?
    self.id == PurchaseRequestStatus.id_for(:order_initiated)
  end

  def cancelled?
    self.id == PurchaseRequestStatus.id_for(:cancelled)
  end

  def closed?
    self.id == PurchaseRequestStatus.id_for(:closed)
  end

  def draft?
    self.id == PurchaseRequestStatus.id_for(:draft)
  end

  def awaiting_approval?
    self.id == PurchaseRequestStatus.id_for(:awaiting_approval)
  end
end
