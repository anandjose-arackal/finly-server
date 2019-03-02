class RateContract < ApplicationRecord

  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :item, optional: true, class_name: 'InventoryLineItem'
  belongs_to :renewal_alert_period, class_name: 'Period', foreign_key: :renewal_alert_period_id
  
  has_many :rate_contract_line_items
  has_many :artifacts, as: :resource, dependent: :destroy

  accepts_nested_attributes_for :rate_contract_line_items
  accepts_nested_attributes_for :artifacts   

  def as_json
    {
      id: id, 
      name: name, 
      vendor_id: vendor_id,
      vendor_name: vendor&.name,
      renewal_alert_number: renewal_alert_number,
      renewal_alert_period_id: renewal_alert_period_id,
      creator_id: creator_id,
      renewable: renewable
    }
  end
end
