class ManualExpense < ActiveRecord::Base
  belongs_to :expense # foreign key expense_id
end
