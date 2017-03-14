# == Schema Information
#
# Table name: per_diem_expenses
#
#  id          :integer          not null, primary key
#  per_diem_id :integer
#  expense_id  :integer
#  quantity    :integer
#  is_deleted  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PerDiemExpense < ActiveRecord::Base
  belongs_to :expense
  belongs_to :per_diem
end
