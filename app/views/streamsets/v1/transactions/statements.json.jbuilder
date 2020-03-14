# These fields are a replica of Payment Ticket Exports
json.result do
  json.array!(@result.paginated_payments) do |payment|
    # standard fields
    json.id payment.id
    json.amount payment.amount.value
    json.created_at payment.created_at.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_ticket_id payment.payment_order&.bank_payment_request&.id
    json.payment_ticket_name payment.payment_order&.bank_payment_request&.name
    
    case payment.receiving_account.class.name
    when 'UserPocket', 'UserWallet', 'Card'
        beneficiary_name = payment.receiving_account&.user&.name
    else
        beneficiary_name = payment.receiving_account&.try(:account_owner).try(:name)
    end

    json.beneficiary_name beneficiary_name
    json.beneficiary_code (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.vendor_id : nil)
    json.beneficiary_pan (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.pan : nil)
    json.beneficiary_msme_number (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.msme_registration_number : nil)
    json.beneficiary_account_name payment.receiving_account.try(:name)
    json.beneficiary_account_number payment.receiving_account.try(:account_number)
    json.beneficiary_ifsc payment.receiving_account.try(:ifsc)
    json.payment_mode payment.payment_mode&.upcase
    json.initiated_by payment.initiating_user&.name
    json.initiater_email payment.initiating_user&.email
    json.payment_order_status payment.payment_order&.bank_payment_request&.status&.name&.humanize
    json.payment_order_schedule_date payment.payment_order&.scheduled_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_order_submitted_date payment.payment_order&.bank_payment_request&.submitted_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_order_processed_date payment.payment_order&.processed_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.bank_reference_number payment.reference_resource&.bank_reference_number
    json.finance_approved_date payment.payment_order&.bank_payment_request&.approved_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.note payment.note

    # extra fields
    json.money_requests({})
    json.money_requests do
      if payment.money_requests.present?
        json.array!(payment.money_requests) do |money_request|
          json.extract! money_request, :id, :name, :bank_reference_number, :source_account
          json.user money_request.user&.json_for_trail({:vendor_show => true})
          json.status money_request.status&.name&.humanize
          json.created_at money_request.created_at&.strftime("%Y-%m-%d %H:%M:%S")
          json.submitted_at money_request.submitted_at&.strftime("%Y-%m-%d %H:%M:%S")
          json.finance_approved_date money_request.approved_at&.strftime("%Y-%m-%d %H:%M:%S")
          json.required_by_date money_request.required_by_date&.strftime("%Y-%m-%d %H:%M:%S")
          json.processed_amount money_request.processed_amount&.value
          json.narration money_request.memo
          json.bank_account do
            json.merge! money_request.user.bank_accounts.default_accounts.first.as_json
          end
        end
      end
    end

    json.user_pockets({})
    json.user_pockets do
      if payment.receiving_account.class.name == 'UserPocket'
        json.extract! (payment.receiving_account), :name, :active
        json.balance payment.receiving_account.balance&.value
        json.currency payment.receiving_account.base_currency&.country_code
      end
    end
  end
end
json.count @result.payments.count