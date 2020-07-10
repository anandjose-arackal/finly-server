class CreateMissedCardTransactions < ApplicationJob

  def perform
    # step 1 - read the file that is sent by Ebix Cash
    filename = "finly_transactions_#{Date.today.strftime("%Y%b%d")}"
    file_path = "#{Dir.home}/ebix_transactions/#{filename}"

    error_logger = Logger.new("#{Rails.root}/log/coh_recon_errors.log")

    result = []

    ############################# PRIMER #####################################
    # The data is sent in this format:
    # Unique ID$Transaction Date$Transaction Amount$Billing Amount$Auth ID$Transaction Mode$Merchant Key$Merchant Details$Response Code$Transaction Type$Serial ID$Product Code$API Ref ID$MCC$Transaction Status$Type
    # ########################################################################
    begin
      CSV.foreach(file_path) do |row|
        # now parse each row for the various cases
        string = row.first
        data = string.split("$")

        transaction_params = extract_transaction_params(data)

        # EBix sends us details of failed transactions as well but we don't need to
        # handle them at our end for the reconciliation, so skip them
        if transaction_params["reference_id"] == "failed"
          result << {"Ebix Reference ID": "", "Success": "No", "Reason for failure": "Failed transaction"}
        end


        card = Card.find_by proxy: transaction_params[:serial_id]
        user = card&.user
        ebix_reference_id = transaction_params[:reference_id]

        if card.blank?
          result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "Card not found"}
          next
        end

        if user.blank?
          result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "User not found"}
          next
        end

        ############ RECON START #############
        #
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        # Case 1: The card transaction is not created
        #
        ct = CardTransaction.find_by(reference_id: ebix_reference_id)
        if ct.blank?
          # this means we're stuck at scratch - i.e. the transaction was not created for some
          # reason, and hence we can call the Card::Transaction::Create to make the transaction
          begin
            @result = Card::Transaction::Create.(transaction_params)
            if @result.success?
              result << {"Ebix Reference ID": ebix_reference_id, "Success": "Yes"}
            else
              result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": @result.messages[:error].to_sentence}
            end
          rescue => error
            error_logger.error("Following transaction could not be created: #{string} because of the following error: #{error.message}")
            error.backtrace.each do |line|
              error_logger.error "\t #{line}"
            end

            # also add to result file with details
            result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "#{error.message}"}
          end

          next
        end

        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        # Case 2: The card transactions is present. We only need to deal with cases where the type of details is "T"
        # This leads to a few sub-cases here
        #
        # For card expenses and ATM withdrawals, we only
        # need to deal with cases where the type of details is either a "T" or an "S"
        if ct.present? && (["T", "S", "F"].include?(ct.type_of_details))

          # small detail about the :type_of_details attribute that we need to take care
          # of and ensure that it is the right one to create a transaction
          if ct.type_of_details == "S" and ct.product_code == "HDFFRG"
            next
          end

          #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          # Case 2.1: Card Transaction is an ATM, but COH is not added
          # the payment will usually be found on the respective card transaction
          # as reference_payment
          if ct.transaction_mode == "ATM" && ct.transaction_type == "Debit"
            # When type_of_details is T, then it's an actual ATM withdrawal
            if ct.type_of_details == "T"
              reference_payment = ct.reference_payment
              # if the reference_payment is present what that means is that the COH has been
              # successfully added to the user's cash pocket and we don't need to do anything else
              if reference_payment.present?
                next
              else
                atm_pocket = user.user_pockets.atm_withdrawal_pockets.first
                payment_request = PaymentRequest.(user, nil, UserPocket.name, :credit, :atm_withdrawal)
                payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, atm_pocket, ct.transaction_amount_value, reference_resource: ct))
                op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
                if op.success?
                  # i.e. if successful, associate this transaction with the payment
                  payment = op.payments.first
                  ct.update(reference_payment_id: op.payments.first&.id)
                  payment.finly_transactions.update(associated_transaction: transaction)
                  return true
                else
                  result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "COH couldn't be added because: #{@result.messages[:error].to_sentence}"}
                end

                next
              end

              # when type of details is F, then it's the fees associated with an ATM withdrawal
            elsif ct.type_of_details == "F"
              card_expense = CardExpense.find_by(card_transaction_id: ct&.id)
              if card_expense.present?
                next
              else
                # only create the if the card expense is not present
                @result = Expense::ExCard::Create.(transaction, card)
                if @result.success?
                  result << {"Ebix Reference ID": ebix_reference_id, "Success": "Yes"}
                else
                  result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "Expense couldn't be created because: #{@result.messages[:error].to_sentence}"}
                end
                next
              end
            end
          end

          #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          # Case 2.2: Card Transaction is present, but no card expense has been created against it
          # first look for the expense with a card_transaction_id of the CT
          if ["ECOM", "POS"].include?(ct.transaction_mode) && ct.transaction_type == "Debit"
            card_expense = CardExpense.find_by(card_transaction_id: ct&.id)
            if card_expense.present?
              next
            else
              @result = Expense::ExCard::Create.(transaction, card)
              if @result.success?
                result << {"Ebix Reference ID": ebix_reference_id, "Success": "Yes"}
              else
                result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "Expense couldn't be created because: #{@result.messages[:error].to_sentence}"}
              end
              next
            end
          end
        elsif ct.present? && (["R", "RF"].include?(ct.type_of_details))
          if ct.transaction_mode == "ATM"
            # there should be a reference payment to this card transaction that would have
            # reduced the respective COH of the user
            reference_payment = ct.reference_payment
            if reference_payment.present?
              next
            else
              atm_pocket = user.user_pockets.atm_withdrawal_pockets.first
              payment_request = PaymentRequest.(user, nil, UserPocket.name, :debit, :cash_on_hand_reversal)
              payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, atm_pocket, ct.transaction_amount_value, reference_resource: self.transaction))
              op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)

              if op.success?
                payment = op.payments.first
                ct.update(reference_payment_id: op.payments.first&.id)
                payment.finly_transactions.update(associated_transaction: ct)
              else
                result << {"Ebix Reference ID": ebix_reference_id, "Success": "No", "Reason for failure": "COH couldn't be reversed because: #{@result.messages[:error].to_sentence}"}
              end
            end
            next
          end
        end
      end
    rescue Errno::ENOENT => error
      # this is the case when the file is not found for the day
      error.backtrace.each do |line|
        error_logger.error "\t #{line}"
      end
    end

  end


  private

  def extract_transaction_params(data)

    # if it's info about failed transactions, just skip this
    if data[0].present? && data[0].downcase == "failed"
      return {"reference_id": "failed"}
    end

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

    transaction_amount_attributes = transaction_amount.present? ? {value: transaction_amount, currency_id: 1} : nil
    billing_amount_attributes = billing_amount.present? ? {value: billing_amount, currency_id: 1} : nil

    transaction_params = {
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
  end

end