class Expense::ExDistance::Base < Expense::Base

  def distance_expense_params
    receipts = nil
    return {} unless params[:expense].present?
    if params[:expense][:receipts_attributes].present?
      if params[:expense][:receipts_attributes].is_a?(Array) and params[:expense][:receipts_attributes][0].present? and params[:expense][:receipts_attributes][0].kind_of?(Hash)
        params[:expense][:receipts_attributes][0][:user_id] = user.id
      elsif params[:expense][:receipts_attributes].kind_of?(Hash)
        params[:expense][:receipts_attributes][:user_id] = user.id
      end
    end
    receipts = params[:expense][:receipts_attributes] if params[:expense].present?
    p = params.require(:expense).permit(:note, :category_id, :date, :expense_type_id, :expense_status_id, :report_id, :reimbursable,
                                        :receipt_id, :receipt, distance_expense_attributes: [:id, distance_attributes: [:value, :id],
                                                                                             locations_attributes: [:latitude, :longitude, :name, :address, :maps_id]])
    # Hack as image upload from API is failing in strong params
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and not p.nil?
    p.permit!
  end
end