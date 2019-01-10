# == Schema Information
#
# Table name: budget_rule_category_mappings
#
#  id             :integer          not null, primary key
#  budget_rule_id :integer          not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BudgetRuleCategoryMapping < ApplicationRecord
  belongs_to :budget_rule, optional: true
  belongs_to :category, optional: true
end
