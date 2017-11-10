class MakeAllCategoriesExistingEm < ActiveRecord::Migration
  def change
    Category.all.update_all(purpose_id: Purpose.id_for(:expense_management))
  end
end
