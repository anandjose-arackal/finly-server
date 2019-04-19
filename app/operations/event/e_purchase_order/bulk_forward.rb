class Event::EPurchaseOrder::BulkForward < Event::EPurchaseOrder::Base
  attr_accessor :result, :forwarded_to_user

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.result = params[:result]
    self.forwarded_to_user = params[:forwarded_to_user]
  end

  def validate
    unless forwarded_to_user.present?
      add_message :error, "No Forwarded To User Found"
    end
  end

  def affected_users
    [user, forwarded_to_user]
  end

  def send_mailer(user)
    # If no purchase orders could be forwarded, don't send mail to forward to user
    return if result[:success].length == 0 && user.id == forwarded_to_user.id
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:result] = self.result
    params[:display_errors] = true unless user.id == forwarded_to_user.id
    ProcurementMailer.delay.purchase_order_bulk_forward(Event::EPurchaseOrder::BulkForward::MailerPresenter.new(user, params))
  end

  def process
    users = mailer_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? # or not user.is_a?(User)
        if user.is_a?(User)
          send_mailer(user)
        end
      end
    end
  end

  def event_id
    nil
  end

  def affected_users
  end

  def notification_affected_users
    []
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    if user.id == forwarded_to_user.id
      "Purchase Orders Forwarded To You"
    else
      "You Forwarded Purchase Orders"
    end
  end

  def mailer_body(user)
    if user.id == forwarded_to_user.id
      "#{self.user.name} has forwarded #{self.result[:success].length} purchase orders to you for approval"
    else
      "You successfully forwarded #{self.result[:success].length} purchase orders to #{forwarded_to_user.name} for approval \n " +
      "#{self.result[:success].length} purchase orders couldn't be forwarded"
    end
  end

  class Event::EPurchaseOrder::BulkForward::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :result, :display_errors

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.result = params[:result]
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
  end
end
