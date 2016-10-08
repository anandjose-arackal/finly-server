class Expense::Manual::Base < Expense::Base

  # will be called when the user is creating a manual expense
  def manual_expense_params
    receipts = nil
    return {} unless params[:expense].present?
    if params[:expense][:receipts_attributes].present?
      if params[:expense][:receipts_attributes].is_a?(Array)
        params[:expense][:receipts_attributes][0][:user_id] = user.id
      else
        params[:expense][:receipts_attributes][:user_id] = user.id
      end
    end
    receipts = params[:expense][:receipts_attributes] if params[:expense].present?
    p = params.require(:expense).permit(:expense_type_id, :expense_status_id, :note, :receipt, :receipt_id, :report_id, :category_id, :date,
                                        amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id, :id])
    # Hack as image upload from API is failing in strong params
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and p.present?
    p.permit!
  end

end