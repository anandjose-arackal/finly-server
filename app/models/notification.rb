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
#  view_role_id         :integer
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
      when "Money Request"
        object = "Money Request"
      when "Expense"
        object = "Expense"
      when "Card"
        object = "Card"
      when "Wallet"
        object = "Finly Account"
      when "Payment"
        object = "Cash"
      else
        # do nothing
    end

    content += object

    action = ""
    case self.action_type_id
      when NotificationActionType.id_for(:notify_submit)
        action = " submitted"
      when NotificationActionType.id_for(:notify_approve)
        action = " approved"
      when NotificationActionType.id_for(:notify_awaiting_approval)
        action += " awaiting approval"
      when NotificationActionType.id_for(:notify_reject)
        action = " rejected"
      when NotificationActionType.id_for(:notify_retract)
        action = " retracted"
      when NotificationActionType.id_for(:notify_unapprove)
        action = " unapproved"
      when NotificationActionType.id_for(:notify_auto_approve)
        action += " auto-approved"
      when NotificationActionType.id_for(:notify_take_control)
        action = " taken control of by Admin"
      when NotificationActionType.id_for(:notify_credit_reimbursement)
        action = " reimbursement credited"
      when NotificationActionType.id_for(:notify_update)
        action = " updated"
      when NotificationActionType.id_for(:notify_comment)
        action = " has a new comment"
      when NotificationActionType.id_for(:notify_cash_withdrawal)
        action = " on hand withdrawn"
      when NotificationActionType.id_for(:notify_cash_load)
        action = " on hand added"
      when NotificationActionType.id_for(:notify_atm_withdrawal)
        action = " withdrawn from ATM"
      when NotificationActionType.id_for(:notify_credit_advance_request)
        action = " credited"
      when NotificationActionType.id_for(:notify_credit)
        action += " credited"
      when NotificationActionType.id_for(:notify_debit)
        action += " debited"
      when NotificationActionType.id_for(:notify_cash_withdrawal_against_report_reimbursement)
        action += " reimbursement deducted from cash on hand"
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
      if user_name.nil? and action_type_id == NotificationActionType.id_for(:notify_auto_approve)
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

    object_prep = retrieve_object_preposition

    content += prep # short for preposition
    case self.action_type_id
      when NotificationActionType.id_for(:notify_submit)
        action = " submitted"
      when NotificationActionType.id_for(:notify_approve)
        action = " approved"
      when NotificationActionType.id_for(:notify_reject)
        action = " rejected"
      when NotificationActionType.id_for(:notify_retract)
        action = " retracted"
      when NotificationActionType.id_for(:notify_unapprove)
        action = " unapproved"
      when NotificationActionType.id_for(:notify_auto_approve)
        action = ""
      when NotificationActionType.id_for(:notify_awaiting_approval)
        action = " approved"
      when NotificationActionType.id_for(:notify_credit_reimbursement)
        action = " credited a reimbursement of"
        object_prep = ""
      when NotificationActionType.id_for(:notify_update)
        action = " updated"
      when NotificationActionType.id_for(:notify_take_control)
        action = " taken control of"
      when NotificationActionType.id_for(:notify_comment)
        action = " commented on"
      when NotificationActionType.id_for(:notify_cash_withdrawal)
        action = " withdrawn an amount of"
      when NotificationActionType.id_for(:notify_cash_load)
        action = " added an amount of"
      when NotificationActionType.id_for(:notify_atm_withdrawal)
        action = " withdrawn an amount of"
      when NotificationActionType.id_for(:notify_credit_reimbursement)
        action = " credited the reimbursement"
      when NotificationActionType.id_for(:notify_credit_advance_request)
        action = " credited an amount of"
      when NotificationActionType.id_for(:notify_credit)
        action = " credited an amount of"
      when NotificationActionType.id_for(:notify_debit)
        action = " debited an amount of"
      when NotificationActionType.id_for(:notify_cash_withdrawal_against_report_reimbursement)
        action = " withdrawn funds from your cash on hand against reimbursement"
      else
        action = ""
    end

    # adding action
    content += action + object_prep

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
        if action_type_id == NotificationActionType.id_for(:notify_credit_reimbursement) || action_type_id == NotificationActionType.id_for(:notify_cash_withdrawal_against_report_reimbursement)
          object = " for your report"
        else
          object = " report"
        end
        r = Report.find_by(id: self.object_id)
        object_name = " : \"#{r.name}\""
        if action_type_id == NotificationActionType.id_for(:notify_auto_approve)
          object_name += " has been auto approved"
        end
        if action_type_id == NotificationActionType.id_for(:notify_awaiting_approval)
          object_name += " and is awaiting your further approval"
        end
      when "Money Request"
        if action_type_id == NotificationActionType.id_for(:notify_credit_advance_request)
          object = " for an money request"
          mr = MoneyRequest.find_by(id: self.object_id)
          object_name = " : \"#{mr.name}\""
        else
          object = " money request"
          mr = MoneyRequest.find_by(id: self.object_id)
          object_name = " : \"#{mr.name}\""
        end
        if action_type_id == NotificationActionType.id_for(:notify_awaiting_approval)
          object_name += " and is awaiting your further approval"
        end
      when "Expense"
        object = " an expense"
        e = Expense.find_by(id: self.object_id)
        object_name = " at #{e.merchant_name}"
      when "Card"
        object = " to your card"
        # c = self.user.cards.first
        # object_name = " with serial no. #{c.proxy}"
      when "Wallet"
        if action_type_id == NotificationActionType.id_for(:notify_credit)
          object = " to your Finly account"
        else
          object = " from your Finly account"
        end
      when "Payment"
        case action_type_id
          when NotificationActionType.id_for(:notify_cash_load)
            object = " to your cash in hand"
          when NotificationActionType.id_for(:notify_cash_withdrawal)
            object = " from your cash in hand"
          else
            # do nothing
        end
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
        path_object = Report.find_by(id: self.path_object_id)
        if path_object.is_deleted?
          path = "reports"
        else
          path = "reports/#{self.path_object_id}"
        end
      when "Money Request"
        path_object = MoneyRequest.find_by(id: self.path_object_id)
        if path_object.is_deleted?
          path = "requests"
        else
          path = "requests/#{self.path_object_id}"
        end
      when "Settlement", "Wallet", "Payment", "Card"
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

  def retrieve_object_preposition
    case object_type
      when "Report"
        object = Report.find_by(id: object_id)
      when "Money Request"
        object = MoneyRequest.find_by(id: object_id)
      else
        return ""
    end
    owner = object.user
    if self.action_type_id == NotificationActionType.id_for(:notify_auto_approve)
      return ""
    elsif self.action_type_id == NotificationActionType.id_for(:notify_submit)
      return " a" if object_type == "Report"
      return " an" if object_type == "Money Request"
    elsif self.user_id == owner.id
      return " your"
    else
      return " " + owner.name + "'s"
    end
  end

end
