class Event::EBankPaymentRequest::EPayment::Failure < Event::EBankPaymentRequest::Base

  attr_accessor :crediting_user

  def init
    super
    self.crediting_user = self.bank_payment_request.trails.last.action_user
  end


  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:bank_payment_request] = self.bank_payment_request
    BankPaymentRequestMailer.delay.send_failure_mail(Event::EBankPaymentRequest::EPayment::Failure::PaymentRequestPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
  end

  def action_name
    "Payment Order Credit Failed"
  end

  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'Crediting user not found'
    end
  end

  def affected_users
    users= [bank_payment_request.owner, self.crediting_user]
    if parent_document_owner.present?
      users += parent_document_owner
    end
    return users
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_credit_failure)
  end

  def set_notification(user)
    # view_role_id = UserRole.id_for(:initiator)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_credit),
                                             action_user_id: crediting_user.id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: UserRole.id_for(:bank_payment_request_creditor),
                                             application: RequestStore.store[:current_app])
      notification.save
  end

  def mailer_subject(user)
    return "Payments for payment order: #{bank_payment_request.name} has failures!"
  end

  def mailer_body(user)
    # if bank_payment_request.owner_id == crediting_user.id
    #   return "You have successfully initiated credit for your Payment Order: #{bank_payment_request.name}"
    # else
    if user.id == crediting_user.id
      "You had initiated the credit of Payment Order: #{bank_payment_request.name} in which following payments have failed:"
    else
      "#{crediting_user.name} had initiated the credit of Payment Order: #{bank_payment_request.name} in which following payments have failed:"
    end
    # end
  end

  class Event::EBankPaymentRequest::EPayment::Failure::PaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user, :body_val, :subject_val, :company, :action_name, :action_url, :view_url, :bank_payment_request

    def initialize(user, params)
      self.user = user
      self.bank_payment_request = params[:bank_payment_request]
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.view_url = generate_view_url
    end

    def to
      user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def validate
      self.bank_payment_request.payment_order.failed? || self.bank_payment_request.payment_order.partially_completed?
    end

    def generate_view_url
      return if self.bank_payment_request.blank?
      suffix = URI.escape("{}")
      url = "#{Constants::BASE_URL_VP}orders/#{bank_payment_request.id}/params=" + suffix
    end
  end



  def bank_payment_request_view_role(user)
    # return UserRole.id_for(:initiator)
    bank_payment_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

  def parent_document_owner
    user_id = bank_payment_request.payment_order.payments.first.send(:document_owner_attribute) rescue nil
    document_owner = user.company.users.find_by_id(user_id)
  end

end