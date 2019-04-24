# == Schema Information
#
# Table name: purchase_request_item_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PurchaseRequestItemStatus < ApplicationRecord

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
        :cancelled,
        :issued_from_inventory,
        :po_created,
        :rejection_in_progress
    ]
  end

  def retracted?
    self.id == PurchaseRequestItemStatus.id_for(:retracted)
  end

  def rejected?
    self.id == PurchaseRequestItemStatus.id_for(:rejected)
  end

  def approved?
    self.id == PurchaseRequestItemStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == PurchaseRequestItemStatus.id_for(:auto_approved)
  end

  def order_initiated?
    self.id == PurchaseRequestItemStatus.id_for(:order_initiated)
  end

  def cancelled?
    self.id == PurchaseRequestItemStatus.id_for(:cancelled)
  end

  def closed?
    self.id == PurchaseRequestItemStatus.id_for(:closed)
  end

  def draft?
    self.id == PurchaseRequestItemStatus.id_for(:draft)
  end

  def awaiting_approval?
    self.id == PurchaseRequestItemStatus.id_for(:awaiting_approval)
  end

  def issued_from_inventory?
    self.id == PurchaseRequestItemStatus.id_for(:issued_from_inventory)
  end

  def po_created?
    self.id == PurchaseRequestItemStatus.id_for(:po_created)
  end

end
