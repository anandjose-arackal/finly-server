# == Schema Information
#
# Table name: budget_criteria_mappings
#
#  id              :integer          not null, primary key
#  budget_id       :integer
#  budgetable_id   :integer
#  budgetable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class BudgetCriteriaMapping < ApplicationRecord

  # many-to-many mapping between budgets and entities
  belongs_to :budget, optional: true
  belongs_to :budgetable, optional: true, polymorphic: true # this will be the reference to the object for whom a budget can be applied (i.e. a criterion - like category, cost center, vendor etc.)
end