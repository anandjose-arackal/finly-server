class RateContract < ApplicationRecord

  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :item, optional: true, class_name: 'InventoryLineItem'
  
  has_many :rate_contract_line_items

  accepts_nested_attributes_for :rate_contract_line_items


  # Renewal alert options in weeks
  enum renewal_alert_options: ['1_week', '2_weeks', '3_weeks']
   
end
