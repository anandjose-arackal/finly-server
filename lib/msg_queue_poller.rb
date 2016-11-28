class MsgQueuePoller

  def self.run

    username = Constants::ItzCash::MSG_QUEUE_USERNAME
    password = Constants::ItzCash::MSG_QUEUE_PASSWORD

    client = Stomp::Connection.new(username, password, "180.179.138.163", 61613, true)
    client.subscribe("/queue/FinlyQueue")

    loop do
      message = client.receive
      # puts message.body

      puts message.body

      data = message.body.split(",")

      # for the split between merchant city and merchant name
      name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
      merchant_name = name_city[0]
      merchant_city = name_city[1]

      trans_params = {reference_id: data[0],
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

      # triggering the operation to create a card transaction
      begin
        result = Card::Transaction::Create.(trans_params)
      rescue
        # todo - log the output to a log file
      end

      # if the creation of an entry on the transaction table fails, log it in a file
      begin
        trans = CardTransaction.create(trans_params)
        unless trans
          # todo - output to log file that transaction that wasn't created
        end
      rescue
        # todo - output to a file the transaction that wasn't created
      end
    end

    client.disconnect
  end
end