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
  belongs_to :purchase_request
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :unit_amount, optional: true, class_name: "Amount"
  belongs_to :estimated_amount, optional: true, class_name: "Amount"

  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'

  accepts_nested_attributes_for :unit_amount, :estimated_amount

  validates :inventory_line_item_id, presence: true
end
