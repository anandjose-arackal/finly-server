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

  scope :with_budgetable_type, -> (budgetable_type) {
    where budgetable_type: budgetable_type
  }

  scope :with_budgetable_id, -> (budgetable_id) {
    where budgetable_id: budgetable_id
  }

  def as_json(options = {})
    {
        id: id,
        budget_group_name: budget_group.name,
        budgetable_id: budgetable_id,
        budgetable_type: budgetable_type,
        budgetable_name: budgetable.name
    }
  end

end
