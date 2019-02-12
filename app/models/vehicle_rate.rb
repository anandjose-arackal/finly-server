# == Schema Information
#
# Table name: vehicle_rates
#
#  id               :integer          not null, primary key
#  vehicle_name     :string(255)      not null
#  rate_id          :integer          not null
#  distance_unit_id :integer          not null
#  policy_id        :integer
#  is_deleted       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class VehicleRate < ApplicationRecord
  include SoftDeletable

  belongs_to :policy, optional: true
  belongs_to :rate, optional: true, class_name: 'Amount'
  belongs_to :distance_unit, optional: true, class_name: 'PhysicalUnit'

  validates :policy_id, presence: true
  validates :rate, presence: true
  validates :distance_unit_id, presence: true

  accepts_nested_attributes_for :rate

  scope :with_id, -> (id) {where id: id}
  scope :with_policy_id, ->(id) {where policy_id: id}

  def rate
    return nil if super.nil?
    Amount.new(value: super.value, currency_id: policy.base_currency_id)
  end

  def as_json(options = {})
    {
        id: id,
        vehicle_name: vehicle_name,
        rate: rate,
        distance_unit: distance_unit,
        policy: policy,
        default_category: policy.distance_expense_config.default_category,
        enforce_category: policy.distance_expense_config.enforce_category
    }
  end


end
