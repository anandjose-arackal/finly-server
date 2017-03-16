class Expense::ExDistance::Base < Expense::Base


  def distance_expense_params
    params.require(:expense).permit(:note, :category_id, :date, :expense_type_id, :expense_status_id,
                                    :receipt_id, :receipt, distance_expense_attributes: [:id, distance_attributes: [:value, :id]])
  end
end