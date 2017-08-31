class Transcriber::Expenses::Base < Transcriber::Base


  def manual_expense_params
    params.require(:expense).permit(:note, :category_id, :date, amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant])
  end
end
