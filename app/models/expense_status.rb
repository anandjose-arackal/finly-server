# == Schema Information
#
# Table name: expense_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseStatus < ActiveRecord::Base


  # delegated from expense model
  def expense_status
    self.name
  end
end
