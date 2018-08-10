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

  accepts_nested_attributes_for :amount

  scope :within_date, -> (start_date, end_date) {
    where('date >= ? AND date <= ?', start_date, end_date)
  }

  scope :joins_amount, -> { joins(:amount) }
  scope :with_users, -> (user_ids) {
    unless user_ids.empty?
      where(user_id: user_ids)
    end
  }
  scope :with_departments, -> (department_ids) {
    unless department_ids.empty?
      where(department_id: department_ids)
    end
  }
  scope :with_locations, -> (location_ids) {
    unless location_ids.empty?
      where(location_id: location_ids)
    end
  }
  scope :with_vendors, -> (vendor_ids) {
    unless vendor_ids.empty?
      where(vendor_id: vendor_ids)
    end
  }
  scope :with_categories, -> (category_ids) {
    unless category_ids.empty?
      where(category_id: category_ids)
    end
  }
  scope :with_cost_centers, -> (cost_center_ids) {
    unless cost_center_ids
      where(cost_center_id: cost_center_ids)
    end
  }
  scope :with_budgetable_entities, -> (budgetable_entities) {
    where(entity_type: budgetable_entities)
  }
  # more or less the same as with_budgetable_entities
  scope :with_entity_type, -> (entity_types) {
    where(entity_type: entity_types)
  }

end