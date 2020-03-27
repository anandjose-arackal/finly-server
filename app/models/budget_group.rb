# == Schema Information
#
# Table name: budget_groups
#
#  id                           :bigint           not null, primary key
#  company_id                   :integer
#  created_by_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  period_id                    :integer
#  purchase_order               :boolean
#  payment                      :boolean
#  expense                      :boolean
#  purchase_request             :boolean
#  invoice                      :boolean
#  name                         :string(255)
#  start_date                   :datetime
#  end_date                     :datetime
#  deleted_at                   :datetime
#  budget_date_type_id          :integer
#  active                       :boolean          default(TRUE)
#  calculated_before_tax_amount :boolean          default(FALSE)
#

class BudgetGroup < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :period, optional: true
  belongs_to :created_by_user, class_name: "User", optional: true
  belongs_to :budget_date_type, optional: true

  has_many :budget_group_criteria, dependent: :destroy
  has_many :budgets, dependent: :destroy

  accepts_nested_attributes_for :budget_group_criteria

  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :check_for_valid_start_end_date

  default_scope { order(created_at: :desc) }

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

  scope :filter_month, -> (month) {
    if month.present?
      where('extract(month from start_date) <= ? AND extract(month from end_date) >= ?', month, month)
    end
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from start_date) = ? OR extract(year from end_date) = ?', year, year)
  }

  scope :active, -> {
    where active: true
  }

  def as_json(options = {})
    {
      id: id,
      name: name,
      created_by_user: created_by_user&.name,
      created_at: created_at.strftime("%d-%b-%Y"),
      period_id: period_id,
      period: period&.name,
      purchase_order: purchase_order,
      invoice: invoice,
      purchase_request: purchase_request,
      payment: payment,
      expense: expense,
      calculated_before_tax_amount: calculated_before_tax_amount,
      start_date: self.start_date&.strftime("%d-%b-%Y"),
      end_date: self.end_date&.strftime("%d-%b-%Y"),
      total_budgets: self.budgets.count
    }
  end

  private

  def check_for_valid_start_end_date
    case self.period_id
    when Period.id_for(:day)
      if end_date - start_date < 1.day
        errors.add(:period, "cannot be less than the difference between start and end dates")
      end
    when Period.id_for(:month)
      if end_date - start_date < 28.days
        errors.add(:period, "cannot be less than the difference between start and end dates")
      end
    when Period.id_for(:week)
      if end_date - start_date < 7.days
        errors.add(:period, "cannot be less than the difference between start and end dates")
      end
    when Period.id_for(:quarter)
      if end_date - start_date < (3.months - 1.day)
        errors.add(:period, "cannot be less than the difference between start and end dates")
      end
    when Period.id_for(:year)
      if end_date - start_date < 365.days
        errors.add(:period, "cannot be less than the difference between start and end dates")
      end
    end
  end
end
