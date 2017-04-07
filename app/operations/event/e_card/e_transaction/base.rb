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
    subject = self.mailer_subject(user)
    body = self.mailer_body(user)
    button_name = self.mailer_button_name(user)
    return unless subject.present? and body.present?
    CardTransactionMailer.delay.send_mail(Event::ECard::ETransaction::Base::MailerPresenter.new(user, transaction, subject, body, button_name))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
      'View'
  end

  class Event::ECard::ETransaction::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :transaction, :user, :body_val, :subject_val, :button_val

    def initialize(user, transaction, subject, body, button_name)
      self.transaction = transaction
      self.user = user
      self.body_val = body
      self.subject_val = subject
      self.button_val = button_name
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
