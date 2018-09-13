# this operation will cancel out the respective expenses that have been returned by the special response file as invalidated
# the input for this file can either come from the admin panel as a file, or directly from the email as a forward

class SpecialResponse::Cancel < BaseOperation

  attr_accessor :special_response_file, :special_response_sheet

  def init
    self.special_response_file = params[:file]
    self.special_response_sheet = ImportUtil.open_spreadsheet(self.special_response_file)
  end

  def process
    (2..special_response_sheet.last_row).each do |i|
      row = self.special_response_sheet.row(i).first
      details = row.split('|')
      request_number = details[1]
      bank_transaction_number = details[2]

      # i.e. only if it's a valid Request Number that was generated from our system it will parsed and refunded to the respective company
      if request_number&.include?("FINLY") && request_number&.length == 20
        bank_transaction = BankTransaction.find_by unique_request_number: request_number

        bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
        payment = bank_transaction.payment
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error), content: "The amount will be refunded to your account shortly").save
        admin_user = AdminUser.find_by(email: 'vivek.a@finly.io')
        company = bank_transaction.company
        original_debit_account = payment.initiating_account
        payment_request = ::PaymentRequest.(admin_user, nil, original_debit_account.class.name, :credit, :corporate_balance_refund, company_id: company.id)
        payment_request.add_payment_item(::PaymentRequest::PaymentItem.(nil, original_debit_account, bank_transaction.amount_value))
        op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
        if op.success?
          refund_payment = op.payment_order.payments.first
          bank_transaction.update(refunded: true)
          refund_payment&.update(original_payment_for_refund_id: payment.id)
        else
          add_message :error, op.messages[:error]
        end
        payment.payment_order.update_order_status
        payment.payment_order.update_processed_amount
      end
    end
  end

  def post_process
    # now execute the balance checker between YesBank's API and our local database
    company = Company.second # i.e. any company that does not have
    # api_balance_op = YesBankApi::Balance::GetBalance.(company)
    # api_balance = api_balance_op.balance.to_f rescue 0
    api_balance = 123412244 # todo - temporary
    database_balance = YesBankCompanyAccount.sum_balances + VendorPaymentWallet.sum_balances

    btl = BalanceTallyLedger.find_by(date: Date.today)
    if btl.blank?
      # storing the balances in a table that tracks balances every day
      btl = BalanceTallyLedger.create(date: Date.today,
                                      api_balance_attributes: {value: api_balance, currency_id: 1},
                                      finly_database_balance_attributes: {value: database_balance, currency_id: 1})
    else
      btl.update(date: Date.today,
                 api_balance_attributes: {id: btl.api_balance.id, value: api_balance, currency_id: 1},
                 finly_database_balance_attributes: {id: btl.finly_database_balance.id, value: database_balance, currency_id: 1})
    end

    previous_day_btl = BalanceTallyLedger.find_by(date: Date.yesterday)
    previous_day_btl_difference = (previous_day_btl&.api_balance_value.to_f - previous_day_btl&.finly_database_balance_value.to_f).abs

    if (api_balance - database_balance).abs > previous_day_btl_difference
      # trigger mailer alert
      Event::EAlert::Create.(nil, title: 'Balance Tally Check Failure', description: "Balance Check between YesBank API and Finly Database failed: Difference is #{(api_balance - database_balance).abs}", subject: 'Balance Tally Check Failure')
    end
  end

end