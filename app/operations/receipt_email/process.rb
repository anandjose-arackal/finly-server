class ReceiptEmail::Process < BackgroundOperation
  attr_accessor :expense, :receipt_email

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:expense_id].blank? and params[:id].blank?)
      add_message :error, 'Error loading attachments'
      return
    end
  end

  def init
    id = (params[:id] or params[:expense_id])
    self.expense = user.expenses.find_by(id: id)
    self.receipt_email = self.expense&.receipt_email
  end

  def validate
    if self.expense.blank? or self.receipt_email.blank?
      add_message :error, 'Attachments not found'
      return
    end
  end

  def process
    self.receipt_email.receipt_email_attachments.each do |attachment|
      if attachment.download_pending?

      end
    end
  end

  def success

  end

end