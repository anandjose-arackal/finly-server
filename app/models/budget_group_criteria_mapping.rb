# == Schema Information
#
# Table name: budget_group_criteria_mappings
#
#  id              :bigint           not null, primary key
#  budget_group_id :integer
#  budgetable_id   :integer
#  budgetable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class BudgetGroupCriteriaMapping < ApplicationRecord

  belongs_to :budget_group
  belongs_to :budgetable, polymorphic: true
end
