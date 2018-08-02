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

  scope :within_date, -> (start_date, end_date) {
    where('date >= ? AND date <= ?', start_date, end_date)
  }

  scope :joins_amount, -> { joins(:amount) }
  scope :with_users, -> (user_ids) {
    where(user_id: user_ids)
  }
  scope :with_departments, -> (department_ids) {
    where(department_id: department_ids)
  }
  scope :with_locations, -> (location_ids) {
    where(location_id: location_ids)
  }
  scope :with_vendors, -> (vendor_ids) {
    where(vendor_id: vendor_ids)
  }
  scope :with_categories, -> (category_ids) {
    where(category_id: category_ids)
  }
  scope :with_cost_centers, -> (cost_center_ids) {
    where(cost_center_id: cost_center_ids)
  }
  scope :with_budgetable_entities, -> (budgetable_entities) {
    where(entity_type: budgetable_entities)
  }

end