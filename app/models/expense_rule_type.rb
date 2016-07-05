# == Schema Information
#
# Table name: expense_rule_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseRuleType < ActiveRecord::Base
end
