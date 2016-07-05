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

  # delegated from expense model
  def expense_type
    self.name
  end

end
