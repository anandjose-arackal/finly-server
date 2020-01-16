# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseType < ApplicationRecord

  has_many :budget_rule_expense_type_mappings
  has_many :budget_rules, through: :budget_rule_expense_type_mappings

  validates :name, presence: true

  VALUES = {manual: 1, card: 2, distance: 3, time: 4, per_diem: 5, cash: 1}


  def self.id_for(type)
    VALUES[type]
  end

  # delegated from expense model
  def expense_type_name
    self.name
  end

  def self.manual_expense_id
    1
  end

  def self.card_expense_id
    2
  end

  def self.distance_expense_id
    3
  end

  def self.time_expense_id
    4
  end

  def self.per_diem_expense_id
    5
  end

  def manual?
    self.id == ExpenseType.id_for(:manual)
  end

  def card?
    self.id == ExpenseType.id_for(:card)
  end

  def distance?
    self.id == ExpenseType.id_for(:distance)
  end

  def time?
    self.id == ExpenseType.id_for(:time)
  end

  def per_diem?
    self.id == ExpenseType.id_for(:per_diem)
  end

  def exportable_name
    if self.manual?
      return "Cash Expense"
    else
      return "#{self.name} Expense"
    end
  end

end
