class FinlyTransaction::Summary < BaseOperation
  attr_accessor :summary, :finly_transactions

  def pre_validate
    unless params.present? and not params&.dig(:finly_transactions).nil?
      add_message :error, 'Finly Transactions not found'
      return
    end
  end

  def init
    self.finly_transactions = params[:finly_transactions]
  end

  def validate
    unless [ActiveRecord::Relation.name, ActiveRecord::AssociationRelation.name, ActiveRecord::Associations::CollectionProxy.name].include?(self.finly_transactions.class.name)
      add_message :error, 'Invalid params'
      return
    end
  end

  def process
    credit_summary = self.finly_transactions.success.credits.purpose_wise_amount
    debit_summary = self.finly_transactions.success.debits.purpose_wise_amount
    self.summary = {credits: [], debits: []}
    PaymentPurpose.all.each do |payment_purpose|
      credits = credit_summary[payment_purpose.id]
      debits = debit_summary[payment_purpose.id]
      case payment_purpose.id
        when PaymentPurpose.id_for(:atm_withdrawal)
          if debits.present?
            summary[:debits] << {name: "ATM Withdrawals", amount: debits}
          end
        when PaymentPurpose.id_for(:card_transaction)
          if credits.present?
            summary[:credits] << {name: "Received via Cashback / Refunds / Reversals", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Spent using Finly Card", amount: debits}
          end
        when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:advance)
          if credits.present?
            summary[:credits] << {name: "Received as Advance", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Sent as Advance", amount: debits}
          end
        when PaymentPurpose.id_for(:reimbursement_outside_finly)
          if credits.present?
            summary[:credits] << {name: "Received as Reimbursement ( Outside Finly )", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Sent Reimbursement ( Outside Finly )", amount: debits}
          end
        when PaymentPurpose.id_for(:reimbursement)
          if credits.present?
            summary[:credits] << {name: "Received as Reimbursement", amount: credits}
          end
        when PaymentPurpose.id_for(:medical_benefit)
          if credits.present?
            summary[:credits] << {name: "Received for Medical Benefits", amount: credits}
          end
        when PaymentPurpose.id_for(:meal_benefit)
          if credits.present?
            summary[:credits] << {name: "Received for Meal Benefits", amount: credits}
          end
        when PaymentPurpose.id_for(:payroll)
          if credits.present?
            summary[:credits] << {name: "Received as Payroll", amount: credits}
          end
        when PaymentPurpose.id_for(:corporate_balance_load)
          if credits.present?
            summary[:credits] << {name: "Added to Company Credits", amount: credits}
          end
          if debits.present?
            # Prolly not possible
          end
        when PaymentPurpose.id_for(:balance_clearance_outside_finly), PaymentPurpose.id_for(:balance_clearance)
          if credits.present?
            summary[:credits] << {name: "Retracted back to your account", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Retracted from your account", amount: debits}
          end
        when PaymentPurpose.id_for(:corporate_balance_refund)

        when PaymentPurpose.id_for(:fees)
          if credits.present?
            # summary[:credits] << "Added from Personal Expenses: <b>₹#{credits}</b>"
            # Not possible?
          end
          if debits.present?
            summary[:debits] << {name: "Fees", amount: debits}
          end
        when PaymentPurpose.id_for(:personal_expense)
          if credits.present?
            summary[:credits] << {name: "Added from Personal Expenses", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Reversed Personal Expenses", amount: debits}
          end
        when PaymentPurpose.id_for(:vendor_payment)
          if credits.present?
            summary[:credits] <<{name: "Reversal from Vendor Payments", amount: credits}
          end
          if debits.present?
            summary[:debits] << {name: "Sent as Vendor Payment", amount: debits}
          end
      end
    end
    self.summary
  end

  def success
    params[:summary] = self.summary
    FinlyTransaction::Summary::SuccessPresenter.new(user, params, messages)
  end

  class FinlyTransaction::Summary::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :summary

    def init
      self.summary = params[:summary]
    end

  end

end