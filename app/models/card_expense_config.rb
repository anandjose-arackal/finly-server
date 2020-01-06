# == Schema Information
#
# Table name: card_expense_configs
#
#  id         :integer          not null, primary key
#  enabled    :boolean          default(TRUE)
#  policy_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardExpenseConfig < ApplicationRecord
  belongs_to :policy, optional: true

  validates :policy_id, presence: true
end
