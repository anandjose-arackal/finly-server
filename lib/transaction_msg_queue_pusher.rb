class TransactionsMsgQueuePusher

  def self.run

    config_file = File.join(Rails.root, 'config', 'msg_queue.yml')
    details = YAML.load(File.open(config_file))
    region_name = details&.dig(:aws, :region_name)
    access_key_id = details&.dig(:aws, :access_key_id)
    secret_access_key = details&.dig(:aws, :secret_access_key)
    username = details&.dig(:itzcash, :MSG_QUEUE_USERNAME)
    password = details&.dig(:itzcash, :MSG_QUEUE_PASSWORD)

    if Rails.env == 'production'
      mq_server_address = details&.dig(:itzcash, :MSG_QUEUE_ADDRESS_PRODUCTION)
    elsif Rails.env == 'itzcash_uat'
      mq_server_address = details&.dig(:itzcash, :MSG_QUEUE_ADDRESS_UAT)
    else
      mq_server_address = details&.dig(:itzcash, :MSG_QUEUE_ADDRESS_TESTING)
    end

    delimiter = '$'

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/transactions_msg_queue_errors.log")

    client = Stomp::Connection.new(username, password, mq_server_address, 61613, true)
    client.subscribe("/queue/FinlyQueue")

    puts "Subscribed!"

    queue_url = details&.dig(:aws, :queue_url)

    sqs_client = Aws::SQS::Client.new(region: region_name, access_key_id: access_key_id, secret_access_key: secret_access_key)

    loop do
      message = client.receive

      puts message.body

      data = message.body.split(delimiter)

      ############## NOW PUSHING THIS DATA INTO THE AWS MESSAGE QUEUE ##########################
      send_message_result = sqs_client.send_message({
                                                 queue_url: queue_url,
                                                 message_body: data
                                             })
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
