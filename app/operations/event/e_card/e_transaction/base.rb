class Event::ECard::ETransaction::Base < Event::SetNotifier
  attr_accessor :transaction

  def pre_validate
    if params.blank? or params[:transaction].blank?
      add_message :error, 'Transaction not found'
      return
    end
  end

  def action_name

  end

  def init
    self.transaction = params[:transaction]
  end

  def validate
    if self.transaction.blank?
      add_message :error, 'Transaction not found'
    end
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    CardTransactionMailer.delay.send_mail(Event::ECard::ETransaction::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View'
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:action_name] = action_name
  end

  class Event::ECard::ETransaction::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :transaction, :user, :body_val, :subject_val, :button_val, :action_name, :company

    def initialize(user, params)
      self.transaction = params[:transaction]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.action_name = params[:action_name]
      self.company = user.company
    end

    def validate
      self.user.present? and self.transaction.present?
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

end
