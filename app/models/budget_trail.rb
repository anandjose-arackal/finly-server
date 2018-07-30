# == Schema Information
#
# Table name: budget_trails
#
#  id             :integer          not null, primary key
#  entity_id      :integer
#  entity_type    :string(255)
#  category_id    :integer
#  cost_center_id :integer
#  location_id    :integer
#  vendor_id      :integer
#  amount_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  department_id  :integer
#  date           :date
#

class BudgetTrail < ActiveRecord::Base

  belongs_to :entity, polymorphic: true
  belongs_to :category
  belongs_to :cost_center
  belongs_to :amount
  belongs_to :vendor, class_name: "YesBankVendor"
  belongs_to :location, class_name: "BranchLocation"
  belongs_to :department
  belongs_to :user

end
