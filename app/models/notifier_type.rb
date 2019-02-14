# == Schema Information
#
# Table name: notifier_types
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


class NotifierType < ApplicationRecord

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
             {key: :report_settled, has_push_notification: true, has_mailer: true,
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
             {key: :settlement_add_settlement, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_debt_clearance, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :settlement_settled, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :wallet_credit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :wallet_debit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :money_request_submit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_approve, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_retract, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_comment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_take_control, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :money_request_unapprove, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :card_transaction, has_push_notification: true, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :auto_reload_card, has_push_notification: false, has_mailer: false,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :admin_summary, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :manager_summary, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :bank_payment_request_submit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_approve, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_unapprove, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_retract, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_comment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_take_control, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_approve_and_forward, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_credit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :bank_payment_request_credit_confirm, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :system_alert, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :payment_order_bulk_download, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :outward_invoice_payment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: true},
             {key: :travel_request_submit, has_push_notification: false, has_mailer: true,
                configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_retract, has_push_notification: false, has_mailer: true,
                configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_request_selection, has_push_notification: false, has_mailer: true,
                configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_reject_selection, has_push_notification: false, has_mailer: true,
                configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_confirm_booking, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_confirm_selection, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_approve_selection, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_approve, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_reject, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             {key: :travel_request_take_control, has_push_notification: false, has_mailer: true,
              configurable_push_notification: false, configurable_mailer: false},
             # Purchase Order
             {key: :purchase_order_submit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_approve, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_unapprove, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_retract, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_comment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_credit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :purchase_order_take_control, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},

             # Inward Invoice
             {key: :invoice_submit, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :invoice_approve, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :invoice_reject, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :invoice_unapprove, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :invoice_retract, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true},
             {key: :invoice_comment, has_push_notification: true, has_mailer: true,
              configurable_push_notification: true, configurable_mailer: true}


            ]

  scope :with_name, ->(name) {where name: name}

  self.class.instance_eval do
    ACTIONS.each do |item|
      define_method "#{item[:key]}_id" do
        ACTIONS.find_index(item) + 1
      end
    end
  end

  def self.id_for(sym)
    NotifierType.with_name(sym)&.first&.id
  end

  def self.seed_data
    ACTIONS.each do |item|
      unless NotifierType.find_by(name: item[:key].to_s)
        NotifierType.create name: item[:key].to_s,
                            has_push_notification: item[:has_push_notification], has_mailer: item[:has_mailer],
                            configurable_push_notification: item[:configurable_push_notification],
                            configurable_mailer: item[:configurable_mailer]
      end
    end
  end

end
