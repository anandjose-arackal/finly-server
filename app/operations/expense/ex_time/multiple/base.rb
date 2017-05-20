class Expense::ExTime::Multiple::Base < BaseOperation
  def extime_multiple_expense_params(params_passed)
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
    p = params_passed.require(:expense).permit(:note, :category_id, :date, :expense_type_id, :expense_status_id, :report_id, :reimbursable,
                                        :receipt_id, :receipt, time_expense_attributes: [:id, time_object_attributes: [:value, :id]])
    # Hack as image upload from API is failing in strong params_passed
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and p.present?
    p.permit!
  end


  # def time_expense_params
  #   receipts = nil
  #   return {} unless params[:expense].present?
  #   if params[:expense][:receipts_attributes].present?
  #     if params[:expense][:receipts_attributes].is_a?(Array) and params[:expense][:receipts_attributes][0].present? and params[:expense][:receipts_attributes][0].kind_of?(Hash)
  #       params[:expense][:receipts_attributes][0][:user_id] = user.id
  #     elsif params[:expense][:receipts_attributes].kind_of?(Hash)
  #       params[:expense][:receipts_attributes][:user_id] = user.id
  #     end
  #   end
  #   receipts = params[:expense][:receipts_attributes] if params[:expense].present?
  #   p = params.require(:expense).permit(:note, :category_id, :date, :expense_type_id, :expense_status_id, :report_id, :reimbursable,
  #                                       :receipt_id, :receipt, time_expense_attributes: [:id, time_object_attributes: [:value, :id]])
  #   # Hack as image upload from API is failing in strong params
  #   receipts = [receipts] unless receipts.is_a?(Array)
  #   p[:receipts_attributes] = receipts if receipts.present? and p.present?
  #   p.permit!
  # end
  
end