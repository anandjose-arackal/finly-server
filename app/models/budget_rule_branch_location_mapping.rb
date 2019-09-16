# == Schema Information
#
# Table name: budget_rule_branch_location_mappings
#
#  id                 :bigint           not null, primary key
#  budget_rule_id     :integer          not null
#  branch_location_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class BudgetRuleBranchLocationMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :branch_location
end
