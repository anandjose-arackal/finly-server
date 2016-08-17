class Expense::Base < BaseOperation

  attr_accessor :expense

  def authorized_user_types
    [:employee]
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

end