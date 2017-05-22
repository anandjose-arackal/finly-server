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
  belongs_to :parent, polymorphic: true

  belongs_to :default_category, class_name: "Category"

  validate :rate_exists_for_enabled
  validates :parent, presence: true

  def default_category_name
    if self.default_category_id
      return Category.find(default_category_id).name
    else
      ""
    end
  end

  def rate
    if self.enabled
      return self.rate_per_km
    else
      return nil
    end
  end

  private

  def rate_exists_for_enabled
    if self.enabled
      if self.rate_per_km.blank?
        errors.add(:rate, "cannot be empty")
      end
    end
  end
end
