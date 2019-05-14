# == Schema Information
#
# Table name: purchase_order_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PurchaseOrderStatus < ApplicationRecord
  include Seedable
  def self.values
    %w( open retracted processing approved rejected auto_approved sent_to_vendor closed voided po_revised vendor_confirmed)
  end

  def display_name
    self.name&.split("_").map(&:capitalize).join(" ")
  end

  def open?
    self.id == PurchaseOrderStatus.id_for(:open)
  end

  def retracted?
    self.id == PurchaseOrderStatus.id_for(:retracted)
  end

  def rejected?
    self.id == PurchaseOrderStatus.id_for(:rejected)
  end

  def processing?
    self.id == PurchaseOrderStatus.id_for(:processing)
  end

  def approved?
    self.id == PurchaseOrderStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == PurchaseOrderStatus.id_for(:auto_approved)
  end

  def sent_to_vendor?
    self.id == PurchaseOrderStatus.id_for(:sent_to_vendor)
  end

  def closed?
    self.id == PurchaseOrderStatus.id_for(:closed)
  end

  def voided?
    self.id == PurchaseOrderStatus.id_for(:voided)
  end

  def po_revised?
    self.id == PurchaseOrderStatus.id_for(:po_revised)
  end

  def vendor_confirmed?
    self.id == PurchaseOrderStatus.id_for(:vendor_confirmed)
  end

  def self.status_ids_for_voidable
    [
        PurchaseOrderStatus.id_for(:approved),
        PurchaseOrderStatus.id_for(:auto_approved),
        PurchaseOrderStatus.id_for(:sent_to_vendor),
        PurchaseOrderStatus.id_for(:vendor_confirmed),
        PurchaseOrderStatus.id_for(:closed)
    ]
  end

  def self.status_ids_for_owner
    [
      PurchaseOrderStatus.id_for(:open),
      PurchaseOrderStatus.id_for(:rejected),
      PurchaseOrderStatus.id_for(:retracted)
    ]
  end

  def self.status_ids_for_reviewer
    [
      PurchaseOrderStatus.id_for(:processing)
    ]
  end
end
