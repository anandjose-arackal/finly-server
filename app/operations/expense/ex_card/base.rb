class Expense::ExCard::Base < Expense::Base
  attr_accessor :transaction, :card

  def update_card_expense_params
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
    p = params.require(:expense).permit(:note, :category_id, :expense_type_id,
                                        card_expense_attributes: [:editable_merchant, :id],
                                        receipts_attributes: [:image, :user_id, :id])
    # Hack as image upload from API is failing in strong params
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and p.present?
    p.permit!
  end

end