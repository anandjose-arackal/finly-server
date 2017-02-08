class BalanceMsgQueuePoller

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

    error_logger = Logger.new("#{Rails.root}/log/balance_msg_queue_errors.log")

    client = Stomp::Connection.new(username, password, mq_server_address, 61613, true)
    client.subscribe("/queue/FinlyBalanceQueue")

    puts "Subscribed!"

    loop do
      message = client.receive

      puts message.body

      delimiter = ","

      data = message.body.split(delimiter)

      # for the split between merchant city and merchant name

      balance_update_params = {card_proxy: data[1],
                               balance_attributes: {value: data[2], currency_id: 1},
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
      if @result.failure? || @result.balance_history.nil?
        error_logger.error("Following history entry : #{message.body} couldn't be created because the operation failed due to the following errors: #{@result.messages[:error]}")
      end

    end

    client.disconnect
  end


end