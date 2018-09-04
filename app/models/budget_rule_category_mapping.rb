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

class BudgetRuleCategoryMapping < ActiveRecord::Base
  belongs_to :budget_rule
  belongs_to :category
end
