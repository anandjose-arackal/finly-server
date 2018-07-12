class BalanceMsgQueuePoller

  def self.run
    
    ####################### Initializing the client and other details for pulling messages from AWS Queue #########
    region_name = ENV["region_name"]
    access_key_id = ENV["access_key_id"]
    secret_access_key = ENV["secret_access_key"]

    sqs_client = Aws::SQS::Client.new(region: region_name, access_key_id: access_key_id, secret_access_key: secret_access_key)
    queue_url = sqs_client.list_queues.queue_urls.first # this will be the url of the message queue we are using

    delimiter = ','

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/balance_msg_queue_errors.log")
    poller = Aws::SQS::QueuePoller.new(queue_url, {client: sqs_client})

    ######################## AWS Code to extract the messages from the queue ###################

    poller.poll do |message|
      puts message.body

      data = message.body.split(delimiter)

      balance_update_params = {card_proxy: data[1],
                               amount_attributes: {value: data[2], currency_id: 1},
                               timestamp: data[3]
                              }

      @rescued = false
      @result = nil
      begin
        @result = Card::Balance::Update.(balance_update_params)
      rescue => error
        error_logger.error("Following history entry : #{message.body} couldn't be created because of the following errors: #{error.message}")
      end

      # if the balance history wasn't created also log it in the log file
      if @result&.failure? || @result.balance_history.nil?
        error_logger.error("Following history entry : #{message.body} couldn't be created because the operation failed due to the following errors: #{@result.messages[:error]}")
      end
    end
  end


end