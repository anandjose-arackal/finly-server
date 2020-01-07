# == Schema Information
#
# Table name: budget_trails
#
#  id                :integer          not null, primary key
#  entity_id         :integer
#  entity_type       :string(255)
#  category_id       :integer
#  cost_center_id    :integer
#  location_id       :integer
#  vendor_id         :integer
#  amount_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  department_id     :integer
#  date              :date
#  sub_department_id :integer
#  procurement_id    :integer
#

class BudgetTrail < ApplicationRecord

  belongs_to :entity, optional: true, polymorphic: true
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :amount, optional: true
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: "Department"
  belongs_to :user, optional: true
  belongs_to :procurement, optional: true

  accepts_nested_attributes_for :amount

  scope :within_date, -> (start_date, end_date) {
    where('date >= ? AND date <= ?', start_date, end_date)
  }

  scope :joins_amount, -> { joins(:amount) }
  scope :with_users, -> (user_ids) {
    unless user_ids.blank?
      where(user_id: user_ids)
    end
  }

  scope :with_departments, -> (department_ids) {
    where department_id: department_ids
  }

  scope :with_departments_or_sub_departments, -> (department_ids) {
    unless department_ids.blank?
      # ids = where(department_id: department_ids).pluck(:id)
      # ids += where(sub_department_id: department_ids).pluck(:id)
      ids = where('department_id IN (?) OR sub_department_id IN (?)', department_ids, department_ids).pluck(:id)
      where(id: ids)
    end
  }

  scope :with_locations, -> (location_ids) {
    unless location_ids.blank?
      where(location_id: location_ids)
    end
  }
  scope :with_vendors, -> (vendor_ids) {
    unless vendor_ids.blank?
      where(vendor_id: vendor_ids)
    end
  }
  scope :with_categories, -> (category_ids) {
    unless category_ids.blank?
      where(category_id: category_ids)
    end
  }
  scope :with_cost_centers, -> (cost_center_ids) {
    unless cost_center_ids.blank?
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

  scope :with_entity_id, -> (ids) {
    where entity_id: ids
  }

end
