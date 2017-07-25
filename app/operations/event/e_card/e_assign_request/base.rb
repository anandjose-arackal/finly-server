class Event::ECard::EAssignRequest::Base <  Event::SetNotifier
  attr_accessor :card_assign_request

  def pre_validate
    unless params&.dig(:card_assign_request).present?
      add_message :error, 'Assign Request not found'
    end
  end

  def init
    self.card_assign_request = params[:card_assign_request]
  end

  def validate
    if self.card_assign_request.blank?
      add_message :error, 'Assign Request not found'
    end
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    CardTransactionMailer.delay.send_mail(Event::ECard::EAssignRequest::Base::MailerPresenter.new(user, params))
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
  end

  class Event::ECard::EAssignRequest::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :card_assign_request, :user, :body_val, :subject_val, :button_val, :company

    def initialize(user, params)
      self.card_assign_request = params[:card_assign_request]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
    end

    def validate
      self.user.present? and self.card_assign_request.present?
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