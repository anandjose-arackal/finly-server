class MsgQueuePoller

  def self.run
    client = Stomp::Connection.new("finly", "Li3Wp4yk", "180.179.138.163", 61613, true)
    client.subscribe("/queue/FinlyQueue")


    # 5.times do
    loop do
      message = client.receive
      # puts message.body

      puts message.body

      data = message.body.split(",")

      # for the split between merchant city and merchant name
      name_city = data[6].split("\t") # splits the sixth field after the comma into name and city
      merchant_name = name_city[0]
      merchant_city = name_city[1]

      trans_params = {reference_id: data[0],
                      transaction_timestamp: data[1],
                      transaction_amount_attributes: {value: data[2], currency_id: 1},
                      auth_transaction_id: data[3],
                      transaction_mode: data[4],
                      itzcash_merchant_key: data[5],
                      merchant_name: merchant_name,
                      merchant_city: merchant_city,
                      response_code: data[7],
                      transaction_type: data[8],
                      serial_id: data[9],
                      product_code: data[10]
                      }

      # # triggering the operation to create a card transaction
      # result = Card::Transaction::Create.(trans_params)
      #
      # # if the transaction operation fails for some reason, log it in the transaction table, and mark it as not expensed
      # unless result.success?
      #   trans_params[:expensed] = false
      # end

      trans = CardTransaction.create(trans_params)

    end

    client.disconnect
    # end
  end
end