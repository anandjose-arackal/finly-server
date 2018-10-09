class Personalizer::Adapters::Company67::ExportTemplates67::AllStatementsTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents

  def pre_validate

  end

  def init
    self.headers = [
        'Date',
        'Type',
        'Purpose',
        'Narration',
        'Credit',
        'Debit',
        'Closing Balance',
        'Status',
        'Transaction ID',
        'Note',
        'Report IDs',
        'Account',
        'Employee',
        'Report ID',
        'Expense ID',
        'Expense Merchant',
        'Expense Narration',
        'Expense Date',
        'Report Name'
    ]
    self.contents = []
    user_ids = Company.find(67).users.pluck(:id)
    user_pocket_ids = UserPocket.where(user_id: user_ids).where(name: 'Cash on Hand').pluck(:id)

    from_date = params&.dig(:filter_date, :from)
    from_date = from_date || (Date.today - 1.month.ago)
    from_date = Date.parse(from_date) if from_date.class.name == 'String'
    to_date = params&.dig(:filter_date, :to)
    to_date = to_date || (Date.today)
    to_date = Date.parse(to_date) if to_date.class.name == 'String'
    finly_transactions = FinlyTransaction.where(company_id: 67).with_date_range(from_date, to_date)

    finly_transactions.success.sort_date_asc.all.each do |finly_transaction|
      credit_amount = nil
      debit_amount = nil
      if finly_transaction.credit?
        credit_amount = finly_transaction.amount.value
      else
        debit_amount = finly_transaction.amount.value
      end
      if ['settlement_against_cash_on_hand', 'settlement_against_advance'].include?(finly_transaction.payment_purpose&.name) && finly_transaction.payment.reference_resource_type == "Report"
        finly_transaction.payment.reference_resource.expenses.with_spent_from_id(user_pocket_ids).each do |expense|
          contents << [
              DateUtils.date_formatted(finly_transaction.date),
              finly_transaction.transaction_type.name.humanize,
              finly_transaction.payment_purpose.name.humanize,
              merchant(finly_transaction),
              nil,
              expense.amount.value,
              finly_transaction.closing_balance&.value,
              finly_transaction.status.name.humanize,
              finly_transaction.transaction_reference_id,
              finly_transaction.payment&.note,
              finly_transaction.payment&.reimbursed_reports&.pluck(:id)&.join(','),
              finly_transaction.finly_account_type,
              (finly_transaction.finly_account.user.name rescue nil),
              finly_transaction.payment.reference_resource_id,
              expense.id,
              expense.merchant_name,
              expense.note,
              expense.date,
              expense.report&.name
          ]
        end
        next
      end
      expenses = nil
      if finly_transaction.payment&.reimbursed_reports.present?
        expenses = Expense.with_report_id(finly_transaction.payment&.reimbursed_reports.pluck(:id))
      end
      if expenses
        expenses.each do |expense|
          c = finly_transaction.credit? ? expense.amount.value : nil
          d = finly_transaction.debit? ? expense.amount.value : nil
          contents << [
              DateUtils.date_formatted(finly_transaction.date),
              finly_transaction.transaction_type.name.humanize,
              finly_transaction.payment_purpose.name.humanize,
              merchant(finly_transaction),
              c,
              d,
              finly_transaction.closing_balance&.value,
              finly_transaction.status.name.humanize,
              finly_transaction.transaction_reference_id,
              finly_transaction.payment&.note,
              expense.report_id,
              finly_transaction.finly_account_type,
              (finly_transaction.finly_account.user.name rescue nil),
              nil,
              expense.id
          ]
        end
      else
        contents << [
            DateUtils.date_formatted(finly_transaction.date),
            finly_transaction.transaction_type.name.humanize,
            finly_transaction.payment_purpose.name.humanize,
            merchant(finly_transaction),
            credit_amount,
            debit_amount,
            finly_transaction.closing_balance&.value,
            finly_transaction.status.name.humanize,
            finly_transaction.transaction_reference_id,
            finly_transaction.payment&.note,
            nil,
            finly_transaction.finly_account_type,
            (finly_transaction.finly_account.user.name rescue nil),
            nil,
            nil
        ]
      end
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

  def merchant(finly_transaction)
    merchant = ''
    if finly_transaction.credit?
      prefix = 'From '
    else
      prefix = 'To '
    end
    case finly_transaction.payment_purpose_id
    when PaymentPurpose.id_for(:atm_withdrawal), PaymentPurpose.id_for(:personal_expense), PaymentPurpose.id_for(:card_transaction)
      merchant = finly_transaction&.associated_transaction&.merchant_name
    when PaymentPurpose.id_for(:vendor_payment)
      merchant = finly_transaction.payment&.receiving_user&.name
      if merchant.present?
        if finly_transaction.credit?
          merchant = "Reversal for #{merchant}'s Payment"
        elsif finly_transaction.debit?
          merchant = "Sent to #{merchant}"
        end
      else
        merchant = 'Vendor Payment'
      end
    when PaymentPurpose.id_for(:corporate_balance_load)
      merchant = 'Corporate Balance Load'
    when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement_outside_finly), PaymentPurpose.id_for(:advance), PaymentPurpose.id_for(:balance_clearance),
        PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:medical_benefit), PaymentPurpose.id_for(:meal_benefit), PaymentPurpose.id_for(:payroll), PaymentPurpose.id_for(:balance_clearance_outside_finly)
      if finly_transaction.payment.blank?
        if finly_transaction.associated_transaction.class.name == CompanyTransaction.name
          merchant = finly_transaction.associated_transaction.merchant_name
        end
      else
        if finly_transaction.payment.initiating_account == finly_transaction.finly_account and finly_transaction.payment.receiving_account.present?
          merchant = prefix
          if [UserWallet, Card].include? finly_transaction.payment.receiving_account.class
            merchant += "#{finly_transaction.payment.receiving_account&.user&.name}'s "
          end
          if [BankAccount].include? finly_transaction.payment.receiving_account.class
            merchant += "#{finly_transaction.payment.receiving_account&.account_owner&.name}'s "
          end
          merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.receiving_account)}"
        elsif finly_transaction.payment.receiving_account == finly_transaction.finly_account and finly_transaction.payment.initiating_account.present?
          merchant = prefix
          if [UserWallet, Card].include? finly_transaction.payment.initiating_account.class
            merchant += "#{finly_transaction.payment.initiating_account&.user&.name}'s "
          end
          if [BankAccount].include? finly_transaction.payment.receiving_account.class
            merchant += "#{finly_transaction.payment.receiving_account&.account_owner&.name}'s "
          end
          merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.initiating_account)}"
        end
      end
    end
    merchant
  end

end