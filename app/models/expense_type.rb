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

  VALUES = {manual: 1, card: 2, distance: 3, time: 4, per_diem: 5}


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

  def self.id_for(item)
    VALUES[item]
  end
end
