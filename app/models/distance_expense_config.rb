# == Schema Information
#
# Table name: distance_expense_configs
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#  rate_id             :integer
#  distance_unit_id    :integer
#  policy_id           :integer          not null
#  enforce_category    :boolean          default(FALSE)
#

class DistanceExpenseConfig < ActiveRecord::Base
  belongs_to :default_category, class_name: 'Category'
  belongs_to :rate, class_name: 'Amount'
  belongs_to :period
  belongs_to :policy

  # validate :rate_exists_for_enabled
  validates :policy_id, presence: true

  accepts_nested_attributes_for :rate

  def rate
    return nil if super.nil?
    Amount.new(value: super.value, currency: policy.base_currency)
  end

  def default_category_name
    default_category&.name || ''
  end

  def rate_value
    return self.rate.value if self.enabled
    nil
  end

  private

  def rate_exists_for_enabled
    if self.enabled
      if self.rate.blank?
        errors.add(:rate, 'cannot be empty')
      end
    end
  end
end
