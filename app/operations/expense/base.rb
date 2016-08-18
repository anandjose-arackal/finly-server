class Expense::Base < BaseOperation

  attr_accessor :expense
  attr_accessor :transaction, :card

  def authorized_user_types
    [:employee]
  end

  # this will be called when the expense is being created - i.e. the moment the card is used, parameters will be created from the transaction object
  def card_expense_params
    currency_id = Currency.find_by(country_code: transaction[:transaction_currency_code]).id

    currency_id = create_new_currency(transaction[:transaction_currency_code]) if currency_id.nil?

    params[:amount_attributes] = {value: transaction.transaction_amount_value, currency_id: currency_id}
    params[:card_expense_attributes] = {editable_merchant: transaction[:merchant_name]} if transaction[:merchant_name]
    params[:expense_type_id] = ExpenseType.card_expense_id
    params[:expense_status_id] = ExpenseStatus.unreported_id
    params[:date] = transaction[:date]

    # todo - temporary, category will be extracted from the mcc-category mapping henceforth
    params[:category_id] = 1
    #######################################################################################

    params.permit(:expense_type_id, :expense_status_id, :note, :category_id, :date,
                  amount_attributes: [:value, :currency_id],
                  card_expense_attributes: [:editable_merchant])
  end


  # this will be called when the merchant, or receipt of the expense needs to be updated, from the user's view of expenses
  def update_card_expense_params
    params[:expense][:card_expense_attributes] = {editable_merchant: params[:expense][:merchant]} if params[:expense][:merchant]
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: user.id}] if params[:expense][:receipt].present?

    params.require(:expense).permit(:note, :category_id,
                                    card_expense_attributes: [:editable_merchant, :id],
                                    receipts_attributes: [:image, :user_id, :id])
  end

  # will be called when the user is creating a manual expense
  def manual_expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:expense][:currency_id] = Currency.first.id
    #################################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: user.id}] if params[:expense][:receipt].present?

    # for manual expenses only
    params[:expense][:expense_type_id] = 1
    # i.e. it's an unreported expense if no report id is present, and unsubmitted if report id is present.
    params[:expense][:expense_status_id] = 2 if params[:expense][:report_id].present?
    params[:expense][:expense_status_id] = 1 if params[:expense][:report_id].nil?

    params.require(:expense).permit(:expense_type_id, :expense_status_id, :note, :receipt, :receipt_id, :report_id, :category_id, :date,
                                    amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id, :id])
  end


  def create_new_currency(currency_code)
    new_curr = Currency.create!(country_code: currency_code)
    new_curr.id
  end
end