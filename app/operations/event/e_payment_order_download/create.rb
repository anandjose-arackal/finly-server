class Event::EPaymentOrderDownload::Create < Event::EPaymentOrderDownload::Base

  def pre_validate
    unless params&.dig(:user).present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:download_url).present?
      add_message :error, 'URL not found'
      return
    end
  end

  def event_id
    NotifierType.id_for(:payment_order_bulk_download)
  end

  def affected_users
    [params[:user]]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    PaymentOrderDownloadMailer.delay.send_mail(Event::EPaymentOrderDownload::Base::MailerPresenter.new(user, params))
  end

  def action_name
    'Payment Order Download URL'
  end

  def mailer_subject(user)
    'Payment Order Download URL'
  end

  def mailer_body(user)
    'You can download your payment order file by clicking on the below link'
  end

  def mailer_button_name(user)
    'Download'
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:action_name] = self.action_name
    params[:download_url] = params&.dig(:download_url)
  end

  class Event::EPaymentOrderDownload::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :body_val, :subject_val, :button_val, :action_name, :company, :download_url_val

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.action_name = params[:action_name]
      self.company = user.company
      self.download_url_val = params[:download_url]
    end

    def validate
      self.user.present?
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def download_url
      Constants::BASE_ASSETS_URL + self.download_url_val
    end

    def button_name
      self.button_val
    end

  end

end
