class Receipt::Base < BackgroundOperation
  attr_accessor :receipt_email

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:receipt_email_id].blank? and params[:id].blank?)
      add_message :error, 'Email not found'
      return
    end
  end

  def init
    id = (params[:id] or params[:receipt_email_id])
    self.receipt_email = self.user.receipt_emails.find_by(id: id)
  end

  def validate
    if self.receipt_email.blank?
      add_message :error, 'Email not found'
      return
    end
  end

end