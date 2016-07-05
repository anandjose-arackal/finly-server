# == Schema Information
#
# Table name: manual_expenses
#
#  id         :integer          not null, primary key
#  expense_id :integer
#  merchant   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ManualExpense < ActiveRecord::Base
  belongs_to :expense # foreign key expense_id

  def merchant_name
    self.merchant
  end
end
