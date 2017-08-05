class MoveExistingPaymentsToNewFormat < ActiveRecord::Migration
  def change
    # first adding the new payment purpose types to db
    PaymentPurpose.seed_data

    # adding initiating and receiving user type for all users
    Payment.all.update_all(initiating_user_type: "User", receiving_user_type: "User")

    # now moving all payments to new format
    Payment.all.each do |payment|
      case payment.payment_type_id
        when PaymentType.id_for(:add_cash_on_hand)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:advance_outside_finly))
          payment.update_attribute(:initiating_account, nil)
          user = User.find(payment.receiving_user_id)
          payment.update_attribute(:receiving_account, user.cash_on_hand)
        when PaymentType.id_for(:deduct_cash_on_hand)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:debit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:advance_outside_finly))
          payment.update_attribute(:initiating_account, nil)
          user = User.find(payment.receiving_user_id)
          payment.update_attribute(:receiving_account, user.cash_on_hand)
        when PaymentType.id_for(:reimbursement_outside_finly)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:reimbursement_outside_finly))
          payment.update_attribute(:initiating_account, nil)
          payment.update_attribute(:receiving_account, nil)
        when PaymentType.id_for(:atm_withdrawal)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:atm_withdrawal))
          payment.update_attribute(:initiating_account, nil)
          user = User.find(payment.receiving_user_id)
          payment.update_attribute(:receiving_account, user.cash_on_hand)
        when PaymentType.id_for(:credit_meal_card)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:meal_benefit))
        when PaymentType.id_for(:credit_reimbursement_card)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:reimbursement))
        when PaymentType.id_for(:credit_medical_card)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:medical_benefit))
        when PaymentType.id_for(:credit_expense_card)
          payment.update_attribute(:payment_type_id, PaymentType.id_for(:credit))
          payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:advance))
        when PaymentType.id_for(:credit)
          case payment.receiving_account_type
            when 'Card', 'UserWallet'
              payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:advance))
          end
        when PaymentType.id_for(:debit)
          case payment.receiving_account_type
            when 'Card', 'UserWallet'
              payment.update_attribute(:payment_purpose_id, PaymentPurpose.id_for(:balance_clearance))
          end
        else
          # do nothing
      end

      case payment.initiating_account_type
        when 'Company'

          itz_cash_account = payment.initiating_user.company.itz_cash_company_account
          payment.update(initiating_account: itz_cash_account)
        else
          # nothing to do here
      end
    end
  end
end
