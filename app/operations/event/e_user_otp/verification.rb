class Event::EUserOtp::Verification < Event::EUserOtp::Base

  def pre_validate
    if params[:user_id].blank?
      add_message :error, 'User not found'
      return
    end
    if params[:otp].blank?
      add_message :error, 'OTP not found'
      return
    end
  end

  def affected_users
    User.where(id: params[:user_id])
  end

  def event_id
    NotifierType.id_for(:user_otp)
  end

  def action_name
    'OTP Verification'
  end

  def send_mailer(user)
    return if user.blank?
    params[:subject] = mailer_subject user
    .delay.send_mail(Event::EUserOtp::Verification::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    '[Finly alert] Please confirm the attempted access'
  end

  # def mailer_body(user)
  #   ''
  # end

  class Event::EUserOtp::Verification::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor  :subject, :otp, :user_agent, :ip, :timestamp

    def initialize(user, params)
      self.user = user

      self.otp = params[:otp]
      self.user_agent = params[:user_agent]
      self.ip = params[:ip]
      self.timestamp = params[:timestamp]

      self.subject = params[:subject]
    end

    def to
      self.user.email
    end

  end

end
