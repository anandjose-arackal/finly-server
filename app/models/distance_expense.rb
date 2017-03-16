# == Schema Information
#
# Table name: distance_expenses
#
#  id          :integer          not null, primary key
#  expense_id  :integer
#  is_deleted  :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  distance_id :integer
#

class DistanceExpense < ActiveRecord::Base

  include SoftDeletable

  belongs_to :expense

  has_one :distance

  validates :expense, presence: true
  validates :distance, presence: true

  accepts_nested_attributes_for :distance
  
end
