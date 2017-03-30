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

class TranscribedExpense < ActiveRecord::Base
  belongs_to :amount
  belongs_to :receipt
  belongs_to :expense
  belongs_to :user

  validates :amount, presence: true
  validates :receipt, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :amount
end
