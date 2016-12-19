# == Schema Information
#
# Table name: notifications
#
#  id                   :integer          not null, primary key
#  notification_type_id :integer
#  user_id              :integer
#  action_user_id       :integer
#  amount_id            :integer
#  object_id            :integer
#  object_type          :string(255)
#  path_object_id       :integer
#  path_object_type     :string(255)
#  action_type_id       :integer
#  changed_from         :string(255)
#  changed_to           :string(255)
#  timestamp            :datetime
#  read                 :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  link                 :text(65535)
#

class Notification < ActiveRecord::Base
  belongs_to :notification_type
  belongs_to :user
  belongs_to :action_type, class_name: "NotificationActionType"
  belongs_to :action_user, class_name: "User"
  belongs_to :amount

  scope :user, -> {where(notification_type_id: NotificationType.id_for(:user))}
  scope :payment, -> {where(notification_type_id: NotificationType.id_for(:payment))}
  scope :card, -> {where(notification_type_id: NotificationType.id_for(:card))}
  scope :report, -> {where(notification_type_id: NotificationType.id_for(:report))}
  scope :expense, -> {where(notification_type_id: NotificationType.id_for(:expense))}
  scope :settlement, -> {where(notification_type_id: NotificationType.id_for(:settlement))}
  scope :advance_request, -> {where(notification_type_id: NotificationType.id_for(:advance_request))}

  accepts_nested_attributes_for :amount

  scope :unread, -> {where read: false}

  def self.default_scope
    order(created_at: :desc)
  end

  validates :timestamp, presence: true
  validates :user_id, presence: true
  validates :notification_type_id, presence: true

  def generate_title
    content = ""
    object = ""
    case object_type
      when "Report"
        object = "Report"
      when "Advance Request"
        object = "Report"
      when "Expense"
        object = "Expense"
      when "Card"
        object = "Card"
      when "Wallet"
        object = "Wallet"
      when "Payment"
        object = "Cash"
      else
        # do nothing
    end

    content += object

    action = ""
    case self.action_type_id
      when NotificationActionType.notify_submit_id
        action = " submitted"
      when NotificationActionType.notify_approve_id
        action = " approved"
      when NotificationActionType.notify_awaiting_approval_id
        action += " awaiting approval"
      when NotificationActionType.notify_reject_id
        action = " rejected"
      when NotificationActionType.notify_retract_id
        action = " retracted"
      when NotificationActionType.notify_unapprove_id
        action = " unapproved"
      when NotificationActionType.notify_auto_approve_id
        action += " auto-approved"
      when NotificationActionType.notify_take_control_id
        action = " taken control of by Admin"
      when NotificationActionType.notify_credit_reimbursement_id
        action = " reimbursement credited"
      when NotificationActionType.notify_update_id
        action = " updated"
      when NotificationActionType.notify_comment_id
        action = " has a new comment"
      when NotificationActionType.notify_cash_withdrawal_id
        action = " in hand withdrawn"
      when NotificationActionType.notify_cash_load_id
        action = " in hand loaded"
      when NotificationActionType.notify_atm_withdrawal_id
        action = " withdrawn from ATM"
      when NotificationActionType.notify_credit_advance_request_id
        action = " credited"
      when NotificationActionType.notify_credit_id
        action += " credited"
      when NotificationActionType.notify_debit_id
        action += " debited"
      else
        # do nothing
    end
    content += action
    return content
  end


  def generate_body(user = nil)
    content = ""

    action_user = User.find_by(id: self.action_user_id)
    if user and action_user and user.id == action_user.id
      user_name = "You"
    else
      user_name = action_user.name rescue nil
      if user_name.nil? and action_type_id == NotificationActionType.notify_auto_approve_id
        user_name = "Your"
      end
    end

    content += user_name
    # preposition selector
    if action_user_id.nil?
      prep = ""
    elsif action_user_id == user_id
      prep = " have"
    else
      prep = " has"
    end

    content += prep # short for preposition
    case self.action_type_id
      when NotificationActionType.notify_submit_id
        action = " submitted a"
      when NotificationActionType.notify_approve_id
        action = " approved a"
      when NotificationActionType.notify_reject_id
        action = " rejected a"
      when NotificationActionType.notify_retract_id
        action = " retracted a"
      when NotificationActionType.notify_unapprove_id
        action = " unapproved a"
      when NotificationActionType.notify_auto_approve_id
        action = ""
      when NotificationActionType.notify_awaiting_approval_id
        action = " approved a"
      when NotificationActionType.notify_credit_reimbursement_id
        action = " credited a reimbursement of"
      when NotificationActionType.notify_update_id
        action = " updated a"
      when NotificationActionType.notify_take_control_id
        action = " taken control of a"
      when NotificationActionType.notify_comment_id
        action = " commented on a"
      when NotificationActionType.notify_cash_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.notify_cash_load_id
        action = " loaded an amount of"
      when NotificationActionType.notify_atm_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.notify_credit_reimbursement_id
        action = " credited a reimbursement of"
      when NotificationActionType.notify_credit_advance_request_id
        action = " credited an amount of"
      when NotificationActionType.notify_credit_id
        action = " credited an amount of"
      when NotificationActionType.notify_debit_id
        action = "debited an amount of"
      else
        action = ""
    end

    # adding action
    content += action

    amount_value = Amount.find_by(id: self.amount_id).value rescue nil
    if amount_value
      amount = " INR " + amount_value.to_s
    end

    # adding amount
    content += amount if amount_value

    object = ""
    object_name = ""
    case object_type
      when "Report"
        if action_type_id == NotificationActionType.notify_credit_reimbursement_id
          object = " for a report"
        else
          object = " report"
        end
        r = Report.find_by(id: self.object_id)
        object_name = " : \"#{r.name}\""
        if action_type_id == NotificationActionType.notify_auto_approve_id
          object_name += " has been auto approved"
        end
        if action_type_id == NotificationActionType.notify_awaiting_approval_id
          object_name += " and is awaiting your further approval"
        end
      when "Advance Request"
        if action_type_id == NotificationActionType.notify_credit_advance_request_id
          object = " for an advance request"
          mr = MoneyRequest.find_by(id: self.object_id)
          object_name = " : \"#{mr.name}\""
        else
          object = "n advance request"
          mr = MoneyRequest.find_by(id: self.object_id)
          object_name = " : \"#{mr.name}\""
        end
        if action_type_id == NotificationActionType.notify_awaiting_approval_id
          object_name += " and is awaiting your further approval"
        end
      when "Expense"
        object = " expense"
        e = Expense.find_by(id: self.object_id)
        object_name = " at #{e.merchant_name}"
      when "Card"
        object = " to your card"
        c = Card.find_by(id: self.object_id)
        object_name = " with serial ID #{c.proxy}"
      when "Wallet"
        if action_type_id == NotificationActionType.notify_credit_id
          object = " to your Finly account"
        else
          object = " from your Finly account"
        end
      when "Payment"
        object = " to your cash in hand"
      else
        # do nothing
    end

    # adding object and corresponding name
    content += object + object_name
    return content

  end

  def generate_link(user)

    base = Constants::BASE_URL
    view = ""
    # debugger
    case view_role_id
      when 3
        view = "\"manager\""
      when 2
        view = "\"finance_manager\""
      when 1
        view = "\"admin\""
      else
        view = "\"personal\""
    end
    suffix = "/params={\"view\":" + view + ",\"preview\":true,\"ref\":1,\"n_id\":#{self.id}"
    path = ""
    case self.path_object_type
      when "Report"
        path = "reports/#{self.path_object_id}"
      when "Advance Request"
        path = "requests/#{self.path_object_id}"
      when "Settlement", "Wallet"
        path = "settlements/"
        if view == "\"personal\"" or view.nil?
          path += "#{user.id}"
        end
        suffix += ",\"view_to_load\":\"payments\""
      when "Card"
        if view == 'personal' or view.nil?
          path = "settings"
        else
          path = "employees"
        end
      when "User"
        if view == 'personal' or view.nil?
          # do nothing
        else
          path = "employees"
        end
      else
        # do nothing
    end
    suffix += "}"

    return base + path + suffix

  end

  def generate_date
    return timestamp.strftime("%d %b %y")
  end

  def generate_time
    return timestamp.strftime("%I:%M %p")
  end

end
