# Used to download email url attachments and create receipts out of them. Currently not being used.
class ReceiptEmail::ProcessEmail < ReceiptEmail::Base

  def process
    download_attachment_urls
    save_receipts
    ReceiptEmail::ExtractData.(user, receipt_email_id: self.receipt_email.id)
    create_expense
  end

  protected
  def download_attachment_urls
    self.receipt_email.receipt_email_attachments.each do |attachment|
      if attachment.download_pending?
        url = attachment.attachment_url
        file_name = attachment.attachment_url_file_name
        file_presenter = File::Download.(self.user, url: url, file_name: file_name)
        if file_presenter&.success?
          attachment.update(original_attachment: file_presenter.file)
        else
          attachment.system_messages.create system_message_type_id: SystemMessageType.id_for(:error), content: 'Error downloading attachment'
        end
      end
    end
  end

  def save_receipts
    self.receipt_email.save_receipt_image
  end

  def create_expense
    return unless self.receipt_email.expense_id.blank? and self.receipt_email.expense_data_extract.present?
    extract = self.receipt_email.expense_data_extract
    # Create expenses for completely and partially extracted emails
    return unless [ExpenseDataExtractStatus.id_for(:success), ExpenseDataExtractStatus.id_for(:partial_extract)].include?(extract.status_id)
    expense_param = {}
    if extract.amount_id.present?
      expense_param[:amount_attributes] = {
          value: extract.amount.value,
          currency_id: extract.amount.currency_id
      }
    end
    if extract.merchant.present?
      expense_param[:manual_expense_attributes] ={merchant_name: extract.merchant}
    end
    expense_param[:date] = extract.datetime
    expense_param[:note] = extract.note
    expense_param[:category_id] = self.receipt_email.user.company.categories.with_name('others')&.first&.id
    expense_param[:user_id] = self.receipt_email.user_id
    self.receipt_email.expense.create expense_param
  end

end