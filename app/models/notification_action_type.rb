class NotificationActionType < ActiveRecord::Base

  VALUES = { submit: 1,
             approve: 2,
             reject: 3,
             retract: 4,
             unapprove: 5,
             reimburse: 6,
             update: 7,
             comment: 8,
             card_load: 9,
             credit: 10,
             debit: 11,
             cash_withdraw: 12,
             cash_load: 13,
             atm_withdrawal: 14,
             auto_approve: 15,
             credit_advance_request: 16,
             credit_reimbursement: 17,
             credit_cash_advance: 18,
             take_control: 19
            }

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end



end