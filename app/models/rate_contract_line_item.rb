class RateContractLineItem < ApplicationRecord

  belongs_to :rate_contract, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :item, optional: true, class_name: 'InventoryLineItem'
end
