# == Schema Information
#
# Table name: budget_group_criteria_mappings
#
#  id                        :bigint           not null, primary key
#  budget_group_criterium_id :integer
#  budgetable_id             :integer
#  budgetable_type           :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#

class BudgetGroupCriteriaMapping < ApplicationRecord

  belongs_to :company, optional: true

  belongs_to :budget_group_criterium
  belongs_to :budgetable, polymorphic: true

  scope :with_budgetable_type, -> (budgetable_type) {
    where budgetable_type: budgetable_type
  }

  scope :with_budgetable_id, -> (budgetable_id) {
    where budgetable_id: budgetable_id
  }

  scope :with_budget_group_criteria_id, -> (budget_group_criteria_id) {
    where(budget_group_criterium_id: budget_group_criteria_id)
  }

  scope :with_budgetable_departments, -> (department_ids) {
    if department_ids.present?
      where(budgetable_type: "Department").where(budgetable_id: department_ids)
    end
  }

  scope :with_budgetable_locations, -> (location_ids) {
    if location_ids.present?
      where(budgetable_type: "BranchLocation").where(budgetable_id: location_ids)
    end
  }

  scope :with_budgetable_cost_centers, -> (cost_center_ids) {
    if cost_center_ids.present?
      where(budgetable_type: "CostCenter").where(budgetable_id: cost_center_ids)
    end
  }

  scope :with_budgetable_vendors, -> (vendor_ids) {
    if vendor_ids.present?
      where(budgetable_type: "YesBankVendor").where(budgetable_id: vendor_ids)
    end
  }

  scope :with_budgetable_users, -> (user_ids) {
    if user_ids.present?
      where(budgetable_type: "User").where(budgetable_id: user_ids)
    end
  }

  scope :with_budgetable_categories, -> (category_ids) {
    if category_ids.present?
      where(budgetable_type: "Category").where(budgetable_id: category_ids)
    end
  }

  def as_json(options = {})
    {
        id: id,
        budget_group_criterium_name: self.budget_group_criterium.name,
        budgetable_id: budgetable_id,
        budgetable_type: budgetable_type,
        budgetable_details: budgetable
    }
  end

end
