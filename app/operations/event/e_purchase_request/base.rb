class Event::EPurchaseRequest::Base < Event::SetNotifier
  attr_accessor :purchase_request, :controlling_users, :workflow_output, :role_id, :include_attachments


  def action_name

  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    ProcurementMailer.delay.send_purchase_order_mail(Event::EPurchaseOrder::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
  end


  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:include_attachments] = self.include_attachments
  end

  def allow_mailer(user, configuration)
    true
  end

end
