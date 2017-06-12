class ReceiptEmail::Expenses::Show < BaseOperation
  attr_accessor :receipt_email, :expense_data_extract

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:receipt_email)&.dig(:email_id).blank?
      add_message :error, 'Email not found'
      return
    end
  end

  def init
    id = params[:receipt_email][:email_id]
    self.receipt_email = self.user.receipt_emails.find_by(id: id)
  end

  def process
    if self.receipt_email.present?
      self.expense_data_extract = self.receipt_email.expense_data_extract
    else

    end
  end

  def success

  end

  class ReceiptEmail::Expenses::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

  end

end