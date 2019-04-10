    # table_name => purchase_request_items
    # 
    #                     :id => :integer,
    #    :purchase_request_id => :integer,
    # :inventory_line_item_id => :integer,
    #              :vendor_id => :integer,
    #   :delivery_location_id => :integer,
    #                :purpose => :text,
    #               :quantity => :integer,
    #         :unit_amount_id => :integer,
    #    :estimated_amount_id => :integer,
    #          :delivery_date => :date,
    #             :created_at => :datetime,
    #             :updated_at => :datetime


class PurchaseRequestItem < ApplicationRecord
  include Transitionable

  belongs_to :purchase_request, optional: true
  belongs_to :item, optional: true
  belongs_to :per_unit_estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :status, optional: true, class_name: 'PurchaseRequestItemStatus', foreign_key: :status_id
  has_many :attachments, as: :resource, dependent: :destroy

  accepts_nested_attributes_for :per_unit_estimated_amount, :attachments, allow_destroy: true

  scope :with_ids, -> (ids) { where id: ids}
  scope :with_id, -> (id) { where id: id }
  scope :non_rejected, -> { where.not rejected: true }

  def update_estimated_amount
    quantity = self.quantity
    per_unit_price = self.per_unit_estimated_amount&.value
    amount = Amount.create(currency_id: 1, value: quantity*per_unit_price) if quantity.present? && per_unit_price.present?
    self.estimated_amount_id = amount.id
    self.save
  end

end
