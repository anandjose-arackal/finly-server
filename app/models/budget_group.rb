# == Schema Information
#
# Table name: budget_groups
#
#  id                 :bigint           not null, primary key
#  company_id         :integer
#  created_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  period_id          :integer
#  purchase_order     :boolean
#  payment            :boolean
#  expense            :boolean
#  purchase_request   :boolean
#  invoice            :boolean
#  name               :string(255)
#

class BudgetGroup < ApplicationRecord
  belongs_to :company
  belongs_to :period
  belongs_to :created_by_user, class_name: "User"

  has_many :budget_group_criteria_mappings
  has_many :budgetables, through: :budget_group_criteria_mappings
  has_many :budgetable_vendors, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Department'


  def as_json(options = {})
    {
      id: id,
      name: name,
      created_by_user: created_by_user&.name,
      purchase_order: purchase_order,
      invoice: invoice,
      purchase_request: purchase_request,
      payment: payment,
      expense: expense
    }
  end
end
