# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class ExpenseType < ActiveRecord::Base

  validates :name, presence: true

  # delegated from expense model
  def expense_type
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
end
