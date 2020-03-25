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
#  budget_amount_id             :integer
#  remaining_amount_id          :integer
#  deleted_at                   :datetime
#  total_consumed_amount_id     :integer
#

class BudgetConsumption < ApplicationRecord

  belongs_to :budget
  belongs_to :budget_amount, class_name: "Amount"
  belongs_to :pending_amount, class_name: "Amount"
  belongs_to :committed_amount, class_name: "Amount"
  belongs_to :pending_payment_amount, class_name: "Amount"
  belongs_to :payment_processing_amount, class_name: "Amount"
  belongs_to :paid_amount, class_name: "Amount"
  belongs_to :remaining_amount, class_name: "Amount"
  belongs_to :total_consumed_amount, class_name: "Amount"

  accepts_nested_attributes_for :budget_amount, :pending_amount, :committed_amount, :pending_payment_amount,
                                :payment_processing_amount, :paid_amount, :remaining_amount, :total_consumed_amount

  def as_json(options = {})
    {
        budget_id: budget.id,
        budget_name: budget.name,
        budget_amount: budget_amount.as_json(rounded: true),
        pending_amount: pending_amount.as_json(rounded: true),
        committed_amount: committed_amount.as_json(rounded: true),
        pending_payment_amount: pending_payment_amount.as_json(rounded: true),
        payment_processing_amount: payment_processing_amount.as_json(rounded: true),
        paid_amount: paid_amount.as_json(rounded: true),
        remaining_amount: remaining_amount.as_json(rounded: true),
        total_consumed_amount: total_consumed_amount.as_json(rounded: true)
    }
  end

  alias_method :spent_amount, :total_consumed_amount
end
