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
#

class DistanceExpenseConfig < ActiveRecord::Base
  belongs_to :default_category, class_name: 'Category'
  belongs_to :rate, class_name: 'Amount'
  belongs_to :period
  belongs_to :policy

  validate :rate_exists_for_enabled
  validates :policy_id, presence: true

  accepts_nested_attributes_for :rate

  def default_category_name
    if self.default_category_id
      return Category.find(default_category_id).name
    else
      ''
    end
  end

  def rate_value
    if self.enabled
      return self.rate.send(self.policy.base_currency.country_code)
    else
      return nil
    end
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
