
# here the messages array can be replaced by a method that reads
# from the file containing all daily transactions
messages = ["1727999197031588$06-oct-2017 17:33:08$400.00$400.00$$$$BranchTopUp$00$Credit$S00094980116$RBLFIN$507291386804$$Approved$T",
"214491627238094748650203481032$06-oct-2017 17:46:35$200.00$200.00$PMGW00351510512$POS$OLCFRE_POSOFFUS$HSTL GALIYA DANTI        SABARKANTHA IN$00$Debit$S00094960043$HDFFIN$$4784$Pending$T",
"608636137760614556520800011980$06-oct-2017 17:50:45$270.00$270.00$PMGW00351511359$POS$OLCFRE_POSOFFUS$SAPNA BOOK HOUSE PVT LTD BANGALORE IN$00$Debit$S00094980116$RBLFIN$$5942$Pending$T",
"272676112044344748650203481313$06-oct-2017 17:57:54$100.00$100.00$PMGW00351512946$POS$OLCFRE_POSOFFUS$IRB Surat Dahisar BoriachNAVSARI IN$00$Debit$S00094960071$HDFFIN$$4784$Pending$T",
"290654161007934748650203480901$06-oct-2017 17:59:14$125.00$125.00$PMGW00351513274$POS$OLCFRE_POSOFFUS$IRB Tumkur Chitradurga ATBANGALORE IN$00$Debit$S00094960030$HDFFIN$$4784$Pending$T",
"1727913361385478$06-oct-2017 18:02:06$10000.00$10000.00$$$$Branch TopUp$00$Credit$S00094980090$RBLFIN$507293125087$$Approved$T",
"691811880098054556520800018373$06-oct-2017 18:10:11$90.00$90.00$PMGW00351515673$POS$OLCFRE_POSOFFUS$MILLENIUM CITY EXPRESS  GURGAON IN$00$Debit$S00094980398$RBLFIN$$4784$Pending0$T"
]

# initializing the log file that will hold the errors if necessary
error_logger = Logger.new("#{Rails.root}/log/transactions_msg_queue_errors.log")

messages.each do |message|

      puts message

      data = message.split('$')

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

      trans_params[:billing_amount_attributes] = billing_amount_attributes if billing_amount_attributes.present?

      if billing_amount_attributes.present?
        trans_params[:transaction_amount_attributes] = billing_amount_attributes
      elsif transaction_amount_attributes.present?
        trans_params[:transaction_amount_attributes] = transaction_amount_attributes
      end

      rescued = false
      @result = nil
      # triggering the operation to create a card transaction
      begin
        @result = Card::Transaction::Create.(trans_params)
      rescue => error
        error_logger.error("Following transaction could not be expensed: #{message} because of the following error: #{error.message}")
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
            error_logger.error("Following transaction could not be created: #{message} because of following errors: #{trans.errors.full_messages}")
          end
        rescue => error
          error_logger.error("Following transaction could not be created : #{message} because of following errors: #{error.message}")
          error.backtrace.each do |line|
            error_logger.error "\t #{line}"
          end
        end
      elsif @result&.failure?
        error_logger.error("Following transaction : #{message} couldn't be created because of the following errors: #{@result.messages[:error].to_sentence}")
      end
end