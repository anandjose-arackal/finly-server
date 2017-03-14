# == Schema Information
#
# Table name: time_expenses
#
#  id             :integer          not null, primary key
#  expense_id     :integer
#  is_deleted     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_object_id :integer
#

class TimeExpense < ActiveRecord::Base

  include SoftDeletable

  belongs_to :expense

  has_one :time_object

  validates :time_object, presence: true

end
