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

    error_logger = Logger.new("#{Rails.root}/log/msg_queue_errors.log")

    client = Stomp::Connection.new(username, password, mq_server_address, 61613, true)
    client.subscribe("/queue/FinlyQueue")

    puts "Subscribed!"

    loop do
      message = client.receive

      puts message.body

      delimiter = ","

      data = message.body.split(delimiter)

      # for the split between merchant city and merchant name

      balance_update_params = {reference_id: data[0],
                              transaction_timestamp: data[1],
                              transaction_amount_attributes: {value: data[2], currency_id: 1},
                              billing_amount_attributes: {value: data[3], currency_id: 1},
                              auth_transaction_id: data[4],
                              transaction_mode: data[5],
                              itzcash_merchant_key: data[6],
                              merchant_name: merchant_name,
                              merchant_city: merchant_city,
                              response_code: data[8],
                              transaction_type: data[9],
                              serial_id: data[10],
                              product_code: data[11]
                              }

    end
  end


end