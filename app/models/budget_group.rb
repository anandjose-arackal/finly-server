# == Schema Information
#
# Table name: budget_groups
#
#  id                 :bigint           not null, primary key
#  company_id         :integer
#  created_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class BudgetGroup < ApplicationRecord
  belongs_to :company
  belongs_to :period

  has_many :budget_group_criteria_mappings
  has_many :budgetables, through: :budget_group_criteria_mappings
  has_many :budgetable_vendors, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Department'
end
