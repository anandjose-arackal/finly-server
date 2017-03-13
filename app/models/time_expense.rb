# == Schema Information
#
# Table name: time_expenses
#
#  id         :integer          not null, primary key
#  expense_id :integer
#  is_deleted :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TimeExpense < ActiveRecord::Base
  belongs_to :expense
end
