class RateContractLineItem < ApplicationRecord

  belongs_to :rate_contract, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :item, optional: true, class_name: 'Item'
  belongs_to :amount

  has_many :artifacts, as: :resource, dependent: :destroy

  validates :location, :item, :start_date, :end_date, :amount, presence: true


  accepts_nested_attributes_for :artifacts, allow_destroy: true
  accepts_nested_attributes_for :amount, allow_destroy: true

end
