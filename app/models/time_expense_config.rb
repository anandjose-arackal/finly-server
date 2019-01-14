# == Schema Information
#
# Table name: time_expense_configs
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#  rate_id             :integer
#  period_id           :integer
#  policy_id           :integer          not null
#

class TimeExpenseConfig < ApplicationRecord
  belongs_to :default_category, optional: true, class_name: "Category"
  belongs_to :rate, optional: true, class_name: "Amount"
  belongs_to :period, optional: true
  belongs_to :policy, optional: true

  accepts_nested_attributes_for :rate

  validate :rate_exists_for_enabled
  validates :policy_id, presence: true

  def rate
    return nil if super.nil?
    Amount.new(value: super.value, currency: policy.base_currency)
  end

  def default_category_name
    default_category&.name || ''
  end

  def rate_value
    if self.enabled
      return self.rate.value
    else
      return nil
    end
  end

  private

  def rate_exists_for_enabled
    if self.enabled
      if self.rate.blank?
        errors.add(:rate, "cannot be empty")
      end
    end
  end
end
