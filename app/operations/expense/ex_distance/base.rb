class Expense::ExDistance::Base < Expense::Base


  def distance_expense_params
    params.require(:expense).permit(:note, :category_id, :date, distance_expense_attributes: [])
  end
end