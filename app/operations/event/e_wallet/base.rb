class Event::EWallet::Base < Event::SetNotifier
  attr_accessor :payment, :from_account, :to_account, :from_account_s, :to_account_s

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
    set_presenter_params
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

  def set_presenter_params
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
  end

  class Event::EWallet::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :payment, :user, :body_val, :subject_val, :button_val

    def initialize(user, params)
      self.payment = params[:payment]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
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
    case payment.payment_type_id
      when PaymentType.id_for(:credit_from_virtual_account_to_wallet)
        self.from_account = :virtual_account
        self.to_account = :wallet
      when PaymentType.id_for(:credit_from_virtual_account_to_card)
        self.from_account = :virtual_account
        self.to_account = :card
      when PaymentType.id_for(:credit_from_wallet_to_wallet)
        self.from_account = :wallet
        self.to_account = :wallet
      when PaymentType.id_for(:credit_from_wallet_to_card)
        self.from_account = :wallet
        self.to_account = :card
      when PaymentType.id_for(:debit_from_wallet_to_wallet)
        self.from_account = :wallet
        self.to_account = :wallet
      when PaymentType.id_for(:debit_from_wallet_to_virtual_account)
        self.from_account = :wallet
        self.to_account = :virtual_account
      when PaymentType.id_for(:debit_from_card_to_virtual_account)
        self.from_account = :card
        self.to_account = :virtual_account
      when PaymentType.id_for(:debit_from_card_to_wallet)
        self.from_account = :card
        self.to_account = :wallet
      when PaymentType.id_for(:debit_from_card_to_card)
        self.from_account = :card
        self.to_account = :card
    end
    self.from_account_s = from_account.to_s
    self.to_account_s = to_account.to_s
    if from_account_s == 'wallet'
      self.from_account_s = 'Finly Account'
    end
    if from_account_s == 'virtual_account'
      self.from_account_s = 'Company Credits'
    end
    if to_account_s == 'wallet'
      self.to_account_s = 'Finly Account'
    end
    if to_account_s == 'virtual_account'
      self.to_account_s = 'Company Credits'
    end
  end

end
