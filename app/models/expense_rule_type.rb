# == Schema Information
#
# Table name: expense_rule_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class ExpenseRuleType < ApplicationRecord

  ACTIONS = {
    'Require Receipt': 1,
    'Require Note': 2,
    'Disallow Expense': 3,
    'Require Receipt Hard Copy': 4
  }

  validates :name, presence: true

  scope :with_name, -> (name) {where name: name}

  def self.seed_data
    count = ExpenseRuleType.count
    ACTIONS.each do |key, value|
      if count == 0 or ExpenseRuleType.with_name(key).blank?
        ExpenseRuleType.create id: value, name: key
      end
    end
  end

end
