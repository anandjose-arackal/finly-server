class TransactionAp < ApplicationRecord

  belongs_to :entity, polymorphic: true
  belongs_to :entity_parent, polymorphic: true
  belongs_to :category
  belongs_to :cost_center
  belongs_to :parent_location, class_name: 'Location'
  belongs_to :location, class_name: 'BranchLocation'
  belongs_to :parent_department, class_name: 'Department'
  belongs_to :department
  belongs_to :vendor, class_name: 'YesBankVendor'
  belongs_to :vendor_location, class_name: 'GstinLocation'
  belongs_to :initiating_account, polymorphic: true
  belongs_to :receiving_account, polymorphic: true
  belongs_to :amount
  belongs_to :user
  belongs_to :user_department, class_name: 'Department'
  belongs_to :user_location, class_name: 'Location'
  belongs_to :user_cost_center, class_name: 'CostCenter'
  belongs_to :amount_before_tax, class_name: 'Amount'
  belongs_to :amount_after_tax, class_name: 'Amount'
  belongs_to :amount_tax, class_name: 'Amount'
  belongs_to :amount_tds, class_name: 'Amount'
  belongs_to :item
  belongs_to :category
  belongs_to :rate_contract
  belongs_to :tax_rate
  belongs_to :procurement
  belongs_to :tds_rate, class_name: 'TdsRatesList'
  belongs_to :policy

end
