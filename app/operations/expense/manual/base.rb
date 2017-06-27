class Expense::Manual::Base < Expense::Base

  # will be called when the user is creating a manual expense
  def manual_expense_params
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
    p = params.require(:expense).permit(:expense_type_id, :expense_status_id, :note, :receipt,
                                        :receipt_id, :report_id, :category_id, :date, :reimbursable,
                                        amount_attributes: [:value, :currency_id],
                                        manual_expense_attributes: [:merchant],
                                        receipts_attributes: [:image, :user_id, :id],
                                        receipt_email_attributes: [:source, :email_id, :sender, :raw_html,
                                                                   :subject, :sent_at, :body, :user_id,
                                                                   receipt_email_attachments_attributes: [:attachment_url, :attachment_url_file_name, :original_attachment]])
    # Hack as image upload from API is failing in strong params
    receipts = [receipts] unless receipts.is_a?(Array)
    p[:receipts_attributes] = receipts if receipts.present? and p.present?
    p.permit!
  end

end
