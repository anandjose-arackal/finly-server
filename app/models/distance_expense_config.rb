# == Schema Information
#
# Table name: distance_expense_configs
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  parent_type         :string(255)
#  rate_per_km         :decimal(10, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#

class DistanceExpenseConfig < ActiveRecord::Base
  belongs_to :parent, polymorphic: true

  belongs_to :default_category, class_name: "Category"
end
