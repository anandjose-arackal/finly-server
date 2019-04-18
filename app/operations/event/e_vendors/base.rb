class Event::EVendors::Base < Event::SetNotifier

  attr_accessor :document, :role_id

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:document].blank?)
      add_message :error, 'Vendor not found'
      return
    end
    unless params[:document].is_a?(::YesBankVendor)
      add_message :error, 'Error loading Vendor'
    end
  end

  def init
    self.document = params[:document]
    self.role_id = params[:role_id]
  end

  def validate
    unless self.document.present?
      add_message :error, "Vendor not found"
    end
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    VendorMailer.delay.send_mail(Event::EVendors::Base::VendorMailerPresenter.new(user, params))
  end

  # def send_sms(user)
  #   return if user.blank? || user.mobile_number.blank?
  #   message = sms_message
  #   # now trigger the API used for sending SMSes
  #   op = Sms::Send.(user, {message: message, mobile_number: user.mobile_number})
  # end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name
  end

  def sms_message
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:role_id] = bank_payment_request_view_role user
  end

  class Event::EVendors::Base::VendorMailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :document, :action_name, :subject_val, :body_val,
                  :event_id, :company, :view_role_id, :view_url, :payment

    def init
      self.document = params[:document]
      self.action_name = params[:action_name]
      self.subject_val = params[:subject]
      self.body_val = params[:body]
      self.event_id = params[:event_id]
      self.company = user.company
      # self.view_role_id = params[:role_id]
      # self.view_url = generate_view_url
    end

    def validate
      self.user.present? && (self.document.present?)
    end

    def recipient
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def generate_view_url
      suffix = URI.escape("{}")
      url = "#{Constants::BASE_URL_VP}vendors/#{document.id}/params=" + suffix
    end
  end
end
