# == Schema Information
#
# Table name: distance_expense_configs
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  parent_type         :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#  rate_id             :integer
#  period_id           :integer
#

class DistanceExpenseConfig < ActiveRecord::Base
  belongs_to :parent, polymorphic: true

  belongs_to :default_category, class_name: "Category"
  belongs_to :rate, class_name: "Amount"
  belongs_to :period

  validate :rate_exists_for_enabled
  validates :parent, presence: true

  accepts_nested_attributes_for :rate
  delegate :rate_value, to: :rate

  def default_category_name
    if self.default_category_id
      return Category.find(default_category_id).name
    else
      ""
    end
  end

  def rate_value
    if self.enabled
      return self.rate.send(self.parent.base_currency.currency_code)
    else
      return nil
    end
  end

  private

  def rate_exists_for_enabled
    if self.enabled
      if self.rate_id.blank?
        errors.add(:rate, "cannot be empty")
      end
    end
  end
end
