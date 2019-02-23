class RateContractLineItem < ApplicationRecord

  belongs_to :rate_contract, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :item, optional: true, class_name: 'InventoryLineItem'

  has_many :artifacts, as: :resource, dependent: :destroy


  accepts_nested_attributes_for :artifacts

end
