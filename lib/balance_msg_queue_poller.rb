class BalanceMsgQueuePoller

  def self.run
    
    ####################### Initializing the client and other details for pulling messages from AWS Queue #########
    region_name = ENV["aws_region_name"]
    access_key_id = ENV["aws_access_key_id"]
    secret_access_key = ENV["aws_secret_access_key"]

    sqs_client = Aws::SQS::Client.new(region: region_name, access_key_id: access_key_id, secret_access_key: secret_access_key)

    queue_url_base = ENV["sqs_queue_url_base"]
    queue_name = "BalanceMessageQueue"

    queue_url = queue_url_base + queue_name

    delimiter = ','

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/balance_msg_queue_errors.log")
    poller = Aws::SQS::QueuePoller.new(queue_url, {client: sqs_client})
    file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_balance_poller.log', sync: true)

    ######################## AWS Code to extract the messages from the queue ###################

    poller.poll do |message|
      puts message.body

      data = message.body.split(delimiter)

      balance_update_params = {card_proxy: data[1],
                               amount_attributes: {value: data[2], currency_id: 1},
                               timestamp: data[3]
                              }
      log_params = balance_update_params.deep_dup
      log_params[:request_id] = Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s)

      @rescued = false
      @result = nil
      begin
        @result = Card::Balance::Update.(balance_update_params)

        log_params[:operation_success] = true
        file_logger.info(log_params)

      rescue => error
        error_logger.error("Following history entry : #{message.body} couldn't be created because of the following errors: #{error.message}")

        stack_trace = error.message
        error.backtrace.each do |line|
          stack_trace += "\n#{line}"
        end
        log_params[:operation_success] = false
        log_params[:failure_reason] = error.message
        log_params[:stacktrace] = stack_trace
        file_logger.warn(log_params)

      end

      # if the balance history wasn't created also log it in the log file
      if @result&.failure? || @result.balance_history.nil?
        error_logger.error("Following history entry : #{message.body} couldn't be created because the operation failed due to the following errors: #{@result.messages[:error]}")

        log_params[:operation_success] = false
        log_params[:failure_reason] = (@result.messages[:error] || 'Unknown error')
        file_logger.warn(log_params)

      end
    end
  end


end