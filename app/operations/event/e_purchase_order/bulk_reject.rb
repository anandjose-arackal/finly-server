class Event::EPurchaseOrder::BulkReject < Event::EPurchaseOrder::Base
  attr_accessor :bulk_reject_result

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.bulk_reject_result = params[:result]
  end

  def validate
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:bulk_reject_result] = self.bulk_reject_result
    ProcurementMailer.delay.purchase_order_bulk_reject(Event::EPurchaseOrder::BulkReject::MailerPresenter.new(user, params))
  end

  def process
    send_mailer(user)
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
    "Purchase Orders rejected in Bulk"
  end

  def mailer_body(user)
    "You have successfully rejected purchase orders"
  end

  class Event::EPurchaseOrder::BulkReject::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :reject_results

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.reject_results = params[:bulk_reject_result]
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
