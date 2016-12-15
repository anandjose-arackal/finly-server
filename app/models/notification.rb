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
      when NotificationActionType.submit_id
        action = " submitted"
      when NotificationActionType.approve_id
        action = " approved"
      when NotificationActionType.reject_id
        action = " rejected"
      when NotificationActionType.retract_id
        action = " retracted"
      when NotificationActionType.unapprove_id
        action = " unapproved"
      when NotificationActionType.auto_approve_id
        action += " auto-approved"
      when NotificationActionType.take_control_id
        action = " taken control of by Admin"
      when NotificationActionType.credit_reimbursement_id
        action = " reimbursement credited"
      when NotificationActionType.update_id
        action = " updated"
      when NotificationActionType.comment_id
        action = " has a new comment"
      when NotificationActionType.cash_withdrawal_id
        action = " in hand withdrawn"
      when NotificationActionType.cash_load_id
        action = " in hand loaded"
      when NotificationActionType.atm_withdrawal_id
        action = " withdrawn from ATM"
      when NotificationActionType.credit_advance_request_id
        action = " credited"
      when NotificationActionType.credit_id
        action += " credited"
      when NotificationActionType.debit_id
        action += "debited"
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
      if user_name.nil? and action_type_id == NotificationActionType.auto_approve_id
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
      when NotificationActionType.submit_id
        action = " submitted a"
      when NotificationActionType.approve_id
        action = " approved a"
      when NotificationActionType.reject_id
        action = " rejected an expense in"
      when NotificationActionType.retract_id
        action = " retracted a"
      when NotificationActionType.unapprove_id
        action = " unapproved a"
      when NotificationActionType.auto_approve_id
        action = ""
      when NotificationActionType.credit_reimbursement_id
        action = " credited a reimbursement of"
      when NotificationActionType.update_id
        action = " updated a"
      when NotificationActionType.take_control_id
        action = " taken control of a"
      when NotificationActionType.comment_id
        action = " commented on a"
      when NotificationActionType.cash_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.cash_load_id
        action = " loaded an amount of"
      when NotificationActionType.atm_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.credit_reimbursement_id
        action = " credited a reimbursement of"
      when NotificationActionType.credit_advance_request_id
        action = " credited an advance request of"
      when NotificationActionType.credit_id
        action = " credited an amount of"
      when NotificationActionType.debit_id
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
        if action_type_id == NotificationActionType.credit_reimbursement_id
          object = " for a report"
        else
          object = " report"
        end
        r = Report.find_by(id: self.object_id)
        object_name = " : \"#{r.name}\""
        if action_type_id == NotificationActionType.auto_approve_id
          object_name += " has been auto approved"
        end
      when "Advance Request"
        object = "n advance request"
        mr = MoneyRequest.find_by(id: self.object_id)
        object_name = " : \"#{mr.name}\""
      when "Expense"
        object = " expense"
        e = Expense.find_by(id: self.object_id)
        object_name = " at #{e.merchant_name}"
      when "Card"
        object = " to your card"
        c = Card.find_by(id: self.object_id)
        object_name = " with serial ID #{c.proxy}"
      when "Wallet"
        object = " to your Finly account"
      when "Payment"
        object = " to your cash in hand"
      else
        # do nothing
    end

    # adding object and corresponding name
    content += object + object_name
    return content

  end

  def generate_link(user, view = nil)

    base = Constants::BASE_URL
    suffix = "/params={\"view\":" + "#{view || "\"personal\""}" + ",\"preview\":true,\"ref\":1,\"n_id\":#{self.id}}"
    path = ""
    case self.path_object_type
      when "Report"
        path = "reports/#{self.path_object_id}"
      when "Settlement"
        path = "settlements/"
        if view == 'personal' or view.nil?
          path += "#{user.id}"
        end
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

    return base + path + suffix

  end

  def generate_date
    return timestamp.strftime("%d %b %y")
  end

  def generate_time
    return timestamp.strftime("%I:%M %p")
  end

end
