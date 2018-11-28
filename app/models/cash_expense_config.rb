# == Schema Information
#
# Table name: cash_expense_configs
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  policy_id           :integer          not null
#

class CashExpenseConfig < ActiveRecord::Base
  belongs_to :policy

  validates :policy_id, presence: true
end
