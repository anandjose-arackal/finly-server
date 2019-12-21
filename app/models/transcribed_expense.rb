# == Schema Information
#
# Table name: transcribed_expenses
#
#  id         :integer          not null, primary key
#  amount_id  :integer
#  date       :date
#  merchant   :text(65535)
#  note       :text(65535)
#  receipt_id :integer
#  expense_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TranscribedExpense < ApplicationRecord
  belongs_to :amount, optional: true
  belongs_to :receipt, optional: true
  belongs_to :expense, optional: true
  belongs_to :user, optional: true

  validates :amount, presence: true
  validates :receipt, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :amount
end
