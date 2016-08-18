class Expense::Card::Base < Expense::Base

  attr_accessor :transaction, :card

  # this will be called when the expense is being created - i.e. the moment the card is used, parameters will be created from the transaction object
  def card_expense_params
    currency_id = Currency.find_by(country_code: transaction[:transaction_currency_code])

    params[:amount_attributes] = {value: transaction[:transaction_amount], currency_id: currency_id}
    params[:card_expense_attributes] = {editable_merchant: transaction[:merchant_name]}
    params[:expense_type_id] = ExpenseType.card_expense_id
    params[:expense_status_id] = ExpenseStatus.unreported_id

    params.permit(:expense_type_id, :expense_status_id, :note, :category_id, :date,
                  amount_attributes: [:value, :currency_id])
  end


  # this will be called when the merchant, or receipt of the expense needs to be updated, from the user's view of expenses
  def update_card_expense_params
    params[:expense][:card_expense_attributes] = {editable_merchant: params[:expense][:merchant]}
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: user.id}] if params[:expense][:receipt].present?

    params.require(:expense).permit(:note, :category_id,
                                    card_expense_attributes: [:editable_merchant, :id],
                                    receipts_attributes: [:image, :user_id, :id])
  end

end