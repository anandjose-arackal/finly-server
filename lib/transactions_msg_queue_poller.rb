class TransactionsMsgQueuePoller


  def self.run

    username = ENV["MSG_QUEUE_USERNAME"]
    password = ENV["MSG_QUEUE_PASSWORD"]

    if Rails.env == 'production'
      mq_server_address = ENV["MSG_QUEUE_ADDRESS_PRODUCTION"]
    elsif Rails.env == 'itzcash_uat'
      mq_server_address = ENV["MSG_QUEUE_ADDRESS_UAT"]
    else
      mq_server_address = ENV["MSG_QUEUE_ADDRESS_TESTING"]
    end

    delimiter = '$'

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/transactions_msg_queue_errors.log")

    client = Stomp::Connection.new(username, password, mq_server_address, 61613, true)
    client.subscribe("/queue/FinlyQueue")

    puts "Subscribed!"

    loop do
      message = client.receive

      puts message.body

      data = message.body.split(delimiter)

      # FAILED, TimeStamp, Amount, RequestType, MerchantKey, MerchantName, ResponseCode, SerialID, ProductCode, AcquirerID, MID, TID, MCC, ErrorMessage
      transaction_timestamp = DateUtils.datetime_in_ist(data[1]) rescue nil
      transaction_amount = data[2] rescue nil
      if data.present? and data[0].downcase == 'failed'
        # Failed transaction
        success = false
        reference_id = nil
        transaction_type = data[3]
        itzcash_merchant_key = data[4]
        merchant_name = data[5]
        response_code = data[6]
        serial_id = data[7]
        product_code = data[8]
        acquirer_id = data[9]
        mid = data[10]
        tid = data[11]
        mcc_code = data[12]
        transaction_message = data[13]
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

      trans_params = {
          reference_id: reference_id,
          transaction_timestamp: transaction_timestamp,
          transaction_amount_attributes: {value: transaction_amount, currency_id: 1},
          billing_amount_attributes: {value: billing_amount, currency_id: 1},
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
          transaction_message: transaction_message
      }

      rescued = false
      @result = nil
      # triggering the operation to create a card transaction
      begin
        @result = Card::Transaction::Create.(trans_params)
      rescue => error
        error_logger.error("Following transaction could not be expensed: #{message.body} because of the following error: #{error.message}")
        error.backtrace.each do |line|
          error_logger.error "\t #{line}"
        end
        rescued = true
      end

      # if the operation is a failure, the transaction key was being added to the hash, so explicitly removing it.
      trans_params.delete(:transaction)

      # if the creation of an entry on the transaction table fails, log it in a file
      if !rescued && @result&.success? && @result&.transaction.nil? and success
        begin
          trans = CardTransaction.new(trans_params)
          unless trans.save
            error_logger.error("Following transaction could not be created: #{message.body} because of following errors: #{trans.errors.full_messages}")
          end
        rescue => error
          error_logger.error("Following transaction could not be created : #{message.body} because of following errors: #{error.message}")
          error.backtrace.each do |line|
            error_logger.error "\t #{line}"
          end
        end
      elsif @result&.failure?
        error_logger.error("Following transaction : #{message.body} couldn't be created because of the following errors: #{@result.messages[:error].to_sentence}")
      end
    end

    # disconnect from the client before exiting
    client.disconnect
  end

end
