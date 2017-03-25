class Transcriber::Expenses::Base < BaseOperation


  def manual_expense_params
    params.require(:expense).permit(:note, :category_id, :date, amount_attributes: [:value], manual_expense_attributes: [:merchant])
  end
end
