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

  scope :user, -> {where(notification_type_id: NotificationType.id_for(:user))}
  scope :payment, -> {where(notification_type_id: NotificationType.id_for(:payment))}
  scope :card, -> {where(notification_type_id: NotificationType.id_for(:card))}
  scope :report, -> {where(notification_type_id: NotificationType.id_for(:report))}
  scope :expense, -> {where(notification_type_id: NotificationType.id_for(:expense))}
  scope :settlement, -> {where(notification_type_id: NotificationType.id_for(:settlement))}
  scope :advance_request, -> {where(notification_type_id: NotificationType.id_for(:advance_request))}

  scope :unread, -> {where read: false}

  validates :timestamp, presence: true
  validates :user_id, presence: true
  validates :notification_type_id, presence: true

  def generate_title
    content = ""
    content += self.object_type

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
      when NotificationActionType.take_control_id
        action = " taken control of"
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
    if user and user.id == action_user.id
      user_name = "You"
    else
      user_name = action_user.name
    end

    content += user_name
    # preposition selector
    if action_user_id == user_id
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
      when NotificationActionType.credit_reimbursement_id
        action = " credited reimbursement for a"
      when NotificationActionType.update_id
        action = " updated a"
      when NotificationActionType.comment_id
        action = " commented on a"
      when NotificationActionType.cash_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.cash_load_id
        action = " loaded an amount of"
      when NotificationActionType.atm_withdrawal_id
        action = " withdrawn an amount of"
      when NotificationActionType.credit_advance_request_id
        action = " credited a reimbursement of"
      when NotificationActionType.credit_advance_request_id
        action = " credited an advance request of"
    end

    # preposition selector
    prep = ""

    # adding action
    content += action

    amount_value = Amount.find_by(id: self.amount_id).value rescue nil
    if amount_value
      amount = " INR " + amount_value.to_s
    end

    # adding amount
    content += amount if amount_value

    # adding object
    content += " " + object_type


  end

  def generate_link
    
  end

  def generate_date
    return timestamp.strftime("%d %b %y")
  end

  def generate_time
    return timestamp.strftime("%I:%M %p")
  end

end
