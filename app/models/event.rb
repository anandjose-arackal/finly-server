# == Schema Information
#
# Table name: events
#
#  id                             :integer          not null, primary key
#  name                           :string(255)      not null
#  has_push_notification          :boolean          not null
#  has_mailer                     :boolean          not null
#  configurable_push_notification :boolean          not null
#  configurable_mailer            :boolean          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#



class Event < ActiveRecord::Base

  ACTIONS = [{key: :report_submit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_approve, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_unapprove, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_retract, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_comment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_expense_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_take_control, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :report_reimbursed, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :user_invite, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_password_reset, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_password_change, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_account_unlock_instructions, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_welcome, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_role_updated, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_manager_updated, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_policy_added, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :user_policy_removed, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_add_cash_advance, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_add_reimbursement, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_debt_clearance, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_settled, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_submit, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_approve, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_retract, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_comment, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_reject, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_take_control, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_unapprove, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true}]

  self.class.instance_eval do
    ACTIONS.each do |item|
      define_method "#{item[:key]}_id" do
        ACTIONS.find_index(item) + 1
      end
    end
  end

end
