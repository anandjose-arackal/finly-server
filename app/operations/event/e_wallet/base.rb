class Event::EWallet::Base < Event::SetNotifier
  attr_accessor :payment, :initiating_account, :receiving_account, :initiating_account_s, :receiving_account_s

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or params[:payment].blank?
      add_message :error, 'Payment not found'
    end
    unless params[:payment].is_a?(::Payment)
      add_message :error, 'Error loading Payment'
    end
  end

  def action_name

  end

  def init
    self.payment = params[:payment]
    return unless self.payment.present?
    load_payment_types
  end

  def validate
    unless self.payment.present?
      add_message :error, 'Payment not found'
    end
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    PaymentMailer.delay.send_mail(Event::EWallet::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View'
  end

  def payment_view_role(user)
    return UserRole.id_for(:employee)
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:payment_note] = payment.note
    params[:role_id] = payment_view_role(user)
  end

  class Event::EWallet::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :payment, :user, :body_val, :subject_val, :button_val, :role_id, :view_url

    def initialize(user, params)
      self.payment = params[:payment]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.role_id = params[:role_id]
      self.view_url = generate_url(role_id).html_safe
    end

    def generate_url(role_id)
      view = ""
      case role_id
        when 3
          view = "\"manager\""
        when 2
          view = "\"finance_manager\""
        when 1
          view = "\"admin\""
        else
          view = "\"personal\""
      end
      suffix = "/params={\"view\":" + view + "}"
      path = "settlements/"
      if view == "\"personal\"" || view.nil?
        path += "#{user.id}"
      end
      url = Constants::BASE_URL + path + suffix
    end

    def validate
      self.user.present? and self.payment.present?
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

    def button_name
      self.button_val
    end

  end

  private

  def load_payment_types
    self.initiating_account = payment.initiating_account_type
    self.receiving_account = payment.receiving_account_type

    case payment.initiating_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        self.initiating_account_s = 'Company Credits'
      when Payment::AccountType::WALLET
        self.initiating_account_s = 'Finly Money'
      when Payment::AccountType::CARD
        self.initiating_account_s = "Finly #{payment.initiating_account.card_program.name} Card"
    end

    case payment.receiving_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        self.receiving_account_s = 'Company Credits'
      when Payment::AccountType::WALLET
        self.receiving_account_s = 'Finly Money'
      when Payment::AccountType::CARD
        self.receiving_account_s = "Finly #{payment.receiving_account.card_program.name} Card"
    end
  end

end
