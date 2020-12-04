# == Schema Information
#
# Table name: purchase_request_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class PurchaseRequestStatus < ApplicationRecord

  include Seedable

  GROUP_OPEN = 90
  GROUP_AWAITING_APPROVAL = 91
  GROUP_APPROVED = 92

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
        :po_created,
        :partially_closed
    ]
  end

  def retracted?
    self.id == PurchaseRequestStatus.id_for(:retracted)
  end

  def rejected?
    self.id == PurchaseRequestStatus.id_for(:rejected)
  end

  # def processing?
  #   self.id == PurchaseRequestStatus.id_for(:processing)
  # end

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

  def partially_closed?
    self.id == PurchaseRequestStatus.id_for(:partially_closed)
  end

  # Status IDs for budget trails which are not calculated into budgets
  def self.status_ids_for_unbudgetables
    [
        PurchaseRequestStatus.id_for(:draft),
        PurchaseRequestStatus.id_for(:retracted),
        PurchaseRequestStatus.id_for(:rejected),
        PurchaseRequestStatus.id_for(:closed),
        PurchaseRequestStatus.id_for(:order_initiated),
        PurchaseRequestStatus.id_for(:cancelled),
        PurchaseRequestStatus.id_for(:po_created),
        PurchaseRequestStatus.id_for(:partially_closed),
    ]
  end
end
