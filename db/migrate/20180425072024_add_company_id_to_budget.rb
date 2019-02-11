class AddCompanyIdToBudget < ActiveRecord::Migration[4.2]
  def change
    add_reference :budgets, :user, index: true, foreign_key: true
    add_reference :budgets, :company, index: true, foreign_key: true
  end
end
