class Expense::Manual::Split < Expense::Manual::Base
  attr_accessor :expenses_params, :receipt

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super
    if params&.(:expense).blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
  end

  def init
    self.expense_params = split_expense_params
  end

  def validate

  end

  protected
  def split_expense_params
    expenses_params = []
    base_params = params.require(:expense).permit(:expense_type_id, :expense_status_id, :receipt,
                                                  :receipt_id, :report_id, :date, :reimbursable,
                                                  manual_expense_attributes: [:merchant],
                                                  receipts_attributes: [:image, :user_id, :id],
                                                  receipt_email_attributes: [:source, :email_id, :sender, :raw_html,
                                                                             :subject, :sent_at, :body, :user_id,
                                                                             receipt_email_attachments_attributes: [:attachment_url, :attachment_url_file_name, :original_attachment]])
    base_custom_fields = (params[:custom_fields] or params[:expense][:custom_fields])
    if base_custom_fields.present?
      base_params[:custom_fields] = base_custom_fields
    end
    params&.dig(:expense, :splits)&.each do |split|
      expense_item_params = base_params.deep_dup
      expense_item_params[:note] = split[:note]
      expense_item_params[:category_id] = split[:category_id]
      expense_item_params[:amount_attributes] = split[:amount_attributes]
      if split[:custom_fields].present?
        if expense_item_params[:custom_fields].nil?
          expense_item_params[:custom_fields] = {}
        end
        expense_item_params[:custom_fields].merge split[:custom_fields]
      end
      expenses_params << expense_item_params
    end
  end

end