class ManualExpense < ActiveRecord::Base
  belongs_to :expense # foreign key expense_id

  def merchant_name
    self.merchant
  end
end
