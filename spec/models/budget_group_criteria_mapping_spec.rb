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

require 'rails_helper'

RSpec.describe BudgetGroupCriteriaMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
