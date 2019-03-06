class RateContractLineItem < ApplicationRecord

  belongs_to :rate_contract, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :item, optional: true, class_name: 'Item'
  belongs_to :amount

  has_many :artifacts, as: :resource, dependent: :destroy

  validates :location, :item, :start_date, :end_date, :amount, presence: true
  validate :end_date_is_after_start_date

  accepts_nested_attributes_for :artifacts, allow_destroy: true
  accepts_nested_attributes_for :amount, allow_destroy: true

  def end_date_is_after_start_date
    if !start_date.blank? && !end_date.blank?
      if end_date < start_date
        errors.add(:end_date, 'cannot be before start date')
        return
      end
    end
  end

end
