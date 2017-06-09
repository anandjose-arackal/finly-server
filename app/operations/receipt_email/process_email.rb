# Used to download email url attachments and create receipts out of them. Currently not being used.
class ReceiptEmail::ProcessEmail < BackgroundOperation
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
        url = attachment.attachment_url
        file_name = attachment.attachment_url_file_name
        file_presenter = File::Download.(self.user, url: url, file_name: file_name)
        if file_presenter&.success?
          attachment.update(original_attachment: file_presenter.file)
          debugger
        else
          attachment.system_messages.create system_message_type_id: SystemMessageType.id_for(:error), content: 'Error downloading attachment'
        end
      end
    end
    self.receipt_email.save_receipt_image
  end

end