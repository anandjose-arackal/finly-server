class Expense::Manual::Multiple::Base < BaseOperation
  def manual_multiple_expense_params(params_passed)
    receipts = nil
    return {} unless params_passed[:expense].present?
    if params_passed[:expense][:receipts_attributes].present?
      if params_passed[:expense][:receipts_attributes].is_a?(Array) and params_passed[:expense][:receipts_attributes][0].present? and params_passed[:expense][:receipts_attributes][0].kind_of?(Hash)
        params_passed[:expense][:receipts_attributes][0][:user_id] = user.id
      elsif params_passed[:expense][:receipts_attributes].kind_of?(Hash)
        params_passed[:expense][:receipts_attributes][:user_id] = user.id
      end
    end
    receipts = params_passed[:expense][:receipts_attributes] if params_passed[:expense].present?
    p = params_passed.require(:expense).permit(:expense_type_id, :expense_status_id, :note, :receipt, :receipt_id, :report_id, :category_id, :date,
                                        amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id, :id])
    # Hack as image upload from API is failing in strong params_passed
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and p.present?
    p.permit!
  end
end