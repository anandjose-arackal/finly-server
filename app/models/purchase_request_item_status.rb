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
        :issued_from_inventory
    ]
  end
end
