# == Schema Information
#
# Table name: budget_consumptions
#
#  id                           :bigint           not null, primary key
#  pending_amount_id            :integer
#  committed_amount_id          :integer
#  pending_payment_amount_id    :integer
#  payment_processing_amount_id :integer
#  paid_amount_id               :integer
#  budget_id                    :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class BudgetConsumption < ApplicationRecord

  belongs_to :budget
  belongs_to :pending_amount, class_name: "Amount"
  belongs_to :committed_amount, class_name: "Amount"
  belongs_to :pending_payment_amount, class_name: "Amount"
  belongs_to :payment_processing_amount, class_name: "Amount"
  belongs_to :paid_amount, class_name: "Amount"
end
