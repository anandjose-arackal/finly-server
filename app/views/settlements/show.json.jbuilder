
json.array! @result.items do |item|
  # json.merge! item.attributes
  if item.is_a?(Report)
    json.extract! item, :id, :name
    json.type 'report'
    if item.final_approver
      json.final_approver item.final_approver.name
    end
    json.reimbursement_amount item.reimbursement_amount.value
    json.status item.status_name
    json.total_amount item.total_amount
  elsif item.is_a?(Payment)
      payment_type_id = item.payment_type_id
      payment_type_s = PaymentType.name_for(payment_type_id)
      if([PaymentType.id_for(:credit_from_virtual_account_to_wallet),
        PaymentType.id_for(:credit_from_virtual_account_to_card),
        PaymentType.id_for(:credit_from_wallet_to_wallet),
        PaymentType.id_for(:credit_from_wallet_to_card),
        PaymentType.id_for(:debit_from_wallet_to_wallet),
        PaymentType.id_for(:debit_from_wallet_to_virtual_account)].include?(payment_type_id))
      if @result.selected_user == item.receiving_user
        payment_type_s = "Receive #{PaymentType.name_for(payment_type_id).downcase}"
      elsif(@result.selected_user == item.initiating_user)
        next if [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
                  PaymentType.id_for(:credit_from_virtual_account_to_card),
                  PaymentType.id_for(:debit_from_wallet_to_virtual_account)].include?(payment_type_id)
        payment_type_s = "Initiate #{PaymentType.name_for(payment_type_id).downcase}"
      else
        next
      end
      json.extract! item, :note, :date
      json.type 'payment'
      json.payment_amount item.amount.value
      json.receiving_user item.receiving_user.name
      json.initiating_user item.initiating_user.name
      json.payment_type payment_type_s
      json.total_amount item.total_amount
    end
  elsif item.is_a?(MoneyRequest)
    json.extract! item, :id, :name, :memo, :required_by_date
    json.type 'money_request'
    if item.final_approver
      json.final_approver item.final_approver.name
    end
    if item.payment.present?
      json.credited_date item.payment.date
    end
    json.request_amount item.total_amount
    json.status item.status_name
    json.payment_mode item.payment_mode_name
    json.total_amount item.total_amount
  end

  # json.merge! report.attributes
  # json.total_amount 10
  # json.total_amount report.total_amount
  # json.final_approver report[:final_approver]
  # ap report
end