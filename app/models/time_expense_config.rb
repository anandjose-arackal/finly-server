# == Schema Information
#
# Table name: time_expense_configs
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  parent_type         :string(255)
#  rate_per_hour       :decimal(10, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#

class TimeExpenseConfig < ActiveRecord::Base
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

  private

  def rate_exists_for_enabled
    if self.enabled
      if self.rate_per_hour.blank?
        errors.add(:rate, "cannot be empty")
      end
    end
  end
end
