# == Schema Information
#
# Table name: notification_action_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NotificationActionType < ActiveRecord::Base

  VALUES = { notify_submit: 1,
             notify_approve: 2,
             notify_reject: 3,
             notify_retract: 4,
             notify_unapprove: 5,
             notify_reimbursement: 6,
             notify_update: 7,
             notify_comment: 8,
             notify_card_load: 9,
             notify_credit: 10,
             notify_debit: 11,
             notify_cash_withdrawal: 12,
             notify_cash_load: 13,
             notify_atm_withdrawal: 14,
             notify_auto_approve: 15,
             notify_credit_advance_request: 16,
             notify_credit_reimbursement: 17,
             notify_credit_cash_advance: 18,
             notify_take_control: 19,
             notify_awaiting_approval: 20
            }

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(action)
    VALUES[action]
  end

end
