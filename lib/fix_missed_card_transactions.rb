class FixMissedCardTransactions
  def self.perform
    messages =[]
    File.readlines("#{Dir.home}/finly_scripts/transaction_missed.log").each do |line|
      messages << line.gsub( / *\n+/, "" )
    end;nil

    failed = []
    messages.each do |message|
      puts message
      data = message.split('$')
      transaction_timestamp = nil
      transaction_amount = nil
      if data.present? and data[0].downcase == 'failed'
        success = false
        reference_id = data[1]
        transaction_timestamp = self.parse_timestamp(data[2])
        transaction_amount = data[3]
        transaction_type = data[4]
        itzcash_merchant_key = data[5]
        merchant_name = data[6]
        response_code = data[7]
        serial_id = data[8]
        product_code = data[9]
        acquirer_id = data[10]
        mid = data[11]
        tid = data[12]
        mcc_code = data[13]
        transaction_message = data[14]
        billing_amount = nil
        auth_transaction_id = nil
        transaction_mode = nil
        api_reference_id = nil
        transaction_status = nil
        type_of_details = nil
      else
        # Successful transactions
        success = true
        reference_id = data[0] rescue nil
        transaction_timestamp = data[1] rescue nil
        transaction_amount = data[2]
        billing_amount = data[3] rescue nil
        auth_transaction_id = data[4] rescue nil
        transaction_mode = data[5] rescue nil
        itzcash_merchant_key = data[6] rescue nil
        merchant_name = data[7].squish rescue nil
        response_code = data[8] rescue nil
        transaction_type = data[9] rescue nil
        serial_id = data[10] rescue nil
        product_code = data[11] rescue nil
        api_reference_id = data[12] rescue nil
        mcc_code = data[13] rescue nil
        transaction_status = data[14] rescue nil
        type_of_details = data[15] rescue nil
        acquirer_id = nil
        mid = nil
        tid = nil
        transaction_message = nil
      end

      transaction_amount_attributes = transaction_amount.present? ? {value: transaction_amount, currency_id: 1} : nil
      billing_amount_attributes = billing_amount.present? ? {value: billing_amount, currency_id: 1} : nil

      trans_params = {
          reference_id: reference_id,
          transaction_timestamp: transaction_timestamp,
          auth_transaction_id: auth_transaction_id,
          transaction_mode: transaction_mode,
          itzcash_merchant_key: itzcash_merchant_key,
          merchant_name: merchant_name,
          merchant_city: nil,
          response_code: response_code,
          transaction_type: transaction_type,
          serial_id: serial_id,
          product_code: product_code,
          api_reference_id: api_reference_id,
          mcc_code: mcc_code,
          transaction_status: transaction_status,
          type_of_details: type_of_details,
          acquirer_id: acquirer_id,
          mid: mid,
          tid: tid,
          transaction_message: transaction_message,
          success: success
      }

      puts trans_params

      trans_params[:billing_amount_attributes] = billing_amount_attributes if billing_amount_attributes.present?
      trans_params[:transaction_amount_attributes] = transaction_amount_attributes if transaction_amount_attributes

      operation = Script::MissedCardTransactionCreate.(trans_params)
      puts "Operation Result: #{operation.success?}"
    end
  end
end