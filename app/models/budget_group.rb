# == Schema Information
#
# Table name: budget_groups
#
#  id                 :bigint           not null, primary key
#  company_id         :integer
#  created_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  period_id          :integer
#  purchase_order     :boolean
#  payment            :boolean
#  expense            :boolean
#  purchase_request   :boolean
#  invoice            :boolean
#  name               :string(255)
#  start_date         :datetime
#  end_date           :datetime
#  deleted_at         :datetime
#

class BudgetGroup < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :period, optional: true
  belongs_to :created_by_user, class_name: "User", optional: true

  has_many :budget_group_criteria
  has_many :budgets

  accepts_nested_attributes_for :budget_group_criteria


  scope :with_id, -> (ids) {where id: ids}
  scope :filter_ids, -> (id) {
    id = id.split(",")
    where id: id
  }

  scope :applicable_to_purchase_orders, -> {
    where purchase_order: true
  }
  scope :applicable_to_expenses, -> {
    where expense: true
  }
  scope :applicable_to_payments, -> {
    where payment: true
  }
  scope :applicable_to_purchase_requests, -> {
    where purchase_request: true
  }
  scope :applicable_to_invoices, -> {
    where invoice: true
  }
  scope :with_period_id, -> (period_id) {
    where period_id: period_id
  }

  scope :filter_search, -> (term) {
    if term.present?
      where('name like ?', "%#{term}%")
    end
  }

  scope :without_id, -> (id) {
    where.not(id: id)
  }


  def as_json(options = {})
    {
      id: id,
      name: name,
      created_by_user: created_by_user&.name,
      created_at: created_at.strftime("%Y-%B-%d"),
      period_id: period_id,
      period: period&.name,
      purchase_order: purchase_order,
      invoice: invoice,
      purchase_request: purchase_request,
      payment: payment,
      expense: expense,
      start_date: self.start_date&.strftime("%Y-%B-%d"),
      end_date: self.end_date&.strftime("%Y-%B-%d"),
      total_budgets: self.budgets.count
    }
  end
end
