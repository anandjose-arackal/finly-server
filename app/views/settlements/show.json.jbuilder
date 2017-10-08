if @result.type.include?('payments')
  json.array!(@result.payments) do |payment|
    payment_type_id = payment.payment_type_id
    payment_type_s = PaymentType.name_for(payment_type_id)
    if [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
        PaymentType.id_for(:credit_from_virtual_account_to_card),
        PaymentType.id_for(:credit_from_wallet_to_wallet),
        PaymentType.id_for(:credit_from_wallet_to_card),
        PaymentType.id_for(:debit_from_wallet_to_wallet),
        PaymentType.id_for(:debit_from_wallet_to_virtual_account)].include?(payment_type_id)
      if @result.selected_user == payment.receiving_user
        payment_type_s = "Receive #{PaymentType.name_for(payment_type_id).downcase}"
      elsif @result.selected_user == payment.initiating_user
        next if [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
                 PaymentType.id_for(:credit_from_virtual_account_to_card),
                 PaymentType.id_for(:debit_from_wallet_to_virtual_account)].include?(payment_type_id)
        payment_type_s = "Initiate #{PaymentType.name_for(payment_type_id).downcase}"
      else
        next
      end
    end
    json.extract! payment, :note, :date
    json.type 'payment'
    json.payment_amount payment.amount.value
    json.receiving_account payment.receiving_account_type_name
    json.initiating_account payment.initiating_account_type_name
    json.initiating_user payment.initiating_user&.name
    json.payment_type payment_type_s
    json.total_amount payment.total_amount
    json.payment_purpose payment.payment_purpose.name.humanize
    json.payment_id payment.id
  end
elsif @result.type.include?('reports')
  json.array!(@result.reports) do |report|
    json.extract! report, :id, :name
    json.type 'report'
    if report.final_approver
      json.final_approver report.final_approver.name
    end
    json.reimbursement_amount report.reimbursable_expenses_total.value rescue 0
    json.card_expenses_total report.card_expenses_total.value rescue 0
    json.cash_expenses_total (report.total_amount - report.card_expenses_total.value) rescue 0
    json.reimbursable_expenses_total report.reimbursable_expenses_total.value rescue 0
    json.non_reimbursable_expenses_total report.non_reimbursable_expenses_total.value rescue 0
    json.currency_symbol report.base_currency_symbol
    json.currency_code report.base_currency_code
    json.status report.status_name
    json.total_amount report.total_amount
  end
elsif @result.type.include?('money_requests')
  json.array!(@result.money_requests) do |money_request|
    json.extract! money_request, :id, :name, :memo, :required_by_date
    json.type 'money_request'
    if money_request.final_approver
      json.final_approver money_request.final_approver.name
    end
    if money_request.payment.present?
      json.credited_date money_request.payment.date
    end
    json.request_amount money_request.total_amount
    json.status money_request.status_name
    json.payment_mode money_request.payment_mode_name
    json.total_amount money_request.total_amount
  end
end