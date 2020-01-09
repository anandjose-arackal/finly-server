# == Schema Information
#
# Table name: budget_rule_department_mappings
#
#  id             :bigint           not null, primary key
#  budget_rule_id :integer          not null
#  department_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BudgetRuleDepartmentMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :department
end
