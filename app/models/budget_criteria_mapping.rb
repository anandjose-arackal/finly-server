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
#  deleted_at      :datetime
#

class BudgetCriteriaMapping < ApplicationRecord

  belongs_to :company, optional: true
  # many-to-many mapping between budgets and entities
  belongs_to :budget, optional: true
  belongs_to :budgetable, optional: true, polymorphic: true # this will be the reference to the object for whom a budget can be applied (i.e. a criterion - like category, cost center, vendor etc.)

  scope :with_budgetable_type, -> (budgetable_type) {
    where budgetable_type: budgetable_type
  }

  scope :with_budgetable_id, -> (budgetable_id) {
    where budgetable_id: budgetable_id
  }


  def as_json(options = {})
    {
        id: id,
        name: name,
        budgetable_id: budgetable_id,
        budgetable_type: budgetable_type,
        budgetable_name: budgetable.name
    }
  end

end
