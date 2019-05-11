class TransactionsMsgQueuePoller

  def self.run


    unless File.exists?('config/aws_config.yml')
      raise 'aws_config.yml not found'
    end

    ####################### Initializing the client and other details for pulling messages from AWS Queue #########
    aws_config = Rails.application.config_for(:aws_config)
    region_name = aws_config["aws_region_name"]
    access_key_id = aws_config["aws_access_key_id"]
    secret_access_key = aws_config["aws_secret_access_key"]

    sqs_client = Aws::SQS::Client.new(region: region_name, access_key_id: access_key_id, secret_access_key: secret_access_key)

    queue_url_base = aws_config["sqs_queue_url_base"]
    queue_name = aws_config["transaction_poller_queue"]

    queue_url = queue_url_base + queue_name
    delimiter = '$'

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/transactions_msg_queue_errors.log")
    poller = Aws::SQS::QueuePoller.new(queue_url, {client: sqs_client})
    file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_transaction_poller.log', sync: true)

    puts "Listening...."
    ######################## AWS Code to extract the messages from the queue ###################

    poller.poll do |message|
      puts message.body

      data = message.body.split(delimiter)

      transaction_timestamp = nil
      transaction_amount = nil
      if data.present? and data[0].downcase == 'failed'
        # Failed transaction
        # Format: FAILED, TimeStamp, Amount, RequestType, MerchantKey, MerchantName, ResponseCode, SerialID, ProductCode, AcquirerID, MID, TID, MCC, ErrorMessage
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

      # todo add billing amount, transaction amount, company and user details
      log_params = trans_params.deep_dup
      log_params[:billing_amount] = billing_amount
      log_params[:transaction_amount] = transaction_amount
      card = Card.find_by_proxy(serial_id)
      user = card&.user
      log_params[:card_id] = card&.id
      log_params[:user_id] = user&.id
      log_params[:user_name] = user&.name
      log_params[:company_id] = user&.company&.id
      log_params[:company_name] = user&.company&.name
      log_params[:request_id] = Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s)

      trans_params[:billing_amount_attributes] = billing_amount_attributes if billing_amount_attributes.present?
      trans_params[:transaction_amount_attributes] = transaction_amount_attributes if transaction_amount_attributes

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

        stack_trace = error.message
        error.backtrace.each do |line|
          stack_trace += "\n#{line}"
        end
        log_params[:operation_success] = false
        log_params[:failure_reason] = 'Card Transaction Create crashed'
        log_params[:stacktrace] = stack_trace
        file_logger.warn(log_params)

        rescued = true
      end

      # if the operation is a failure, the transaction key was being added to the hash, so explicitly removing it.
      trans_params.delete(:transaction)

      # if the creation of an entry on the transaction table fails, log it in a file
      if !rescued && @result&.success? && @result&.transaction.nil? and success
        begin
          trans = CardTransaction.new(trans_params)
          if trans.save

            log_params[:operation_success] = true
            log_params[:failure_reason] = 'CardTransaction created separately as Card::Transaction::Create did not create it'
            file_logger.warn(log_params)

          else
            error_logger.error("Following transaction could not be created: #{message.body} because of following errors: #{trans.errors.full_messages}")

            log_params[:operation_success] = false
            log_params[:failure_reason] = "CardTransaction could not be created with the reason : #{trans.errors.full_messages}"
            file_logger.warn(log_params)

          end
        rescue => error
          error_logger.error("Following transaction could not be created : #{message.body} because of following errors: #{error.message}")
          error.backtrace.each do |line|
            error_logger.error "\t #{line}"
          end

          stack_trace = error.message
          error.backtrace.each do |line|
            stack_trace += "\n#{line}"
          end
          log_params[:operation_success] = false
          log_params[:failure_reason] = "CardTransaction Create failed with a crash"
          log_params[:stacktrace] = stack_trace
          file_logger.warn(log_params)

        end
      elsif @result&.failure?
        error_logger.error("Following transaction : #{message.body} couldn't be created because of the following errors: #{@result.messages[:error].to_sentence}")

        log_params[:operation_success] = false
        log_params[:failure_reason] = "CardTransaction could not be created with the reason : #{@result.messages[:error].to_sentence}"
        file_logger.warn(log_params)

      elsif @result&.success? and @result&.transaction.present?

        log_params[:operation_success] = true
        file_logger.info(log_params)

      end
    end

    # disconnect from the client before exiting
    client.disconnect
  end

  def self.parse_timestamp(string)
    year = Date.today.year
    month = string[0..1]&.to_i
    day = string[2..3]&.to_i
    hour = string[4..5]&.to_i
    minute = string[6..7]&.to_i
    second = string[8..9]&.to_i
    timestamp = DateTime.new(year, month, day, hour, minute, second, 'IST') rescue nil
  end

end
