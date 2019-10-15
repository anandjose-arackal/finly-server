class Bbps::BillerDetails < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
    end
  end

  setup_defaults
  path "billFetch"
  dummy_response(
      {
          success: "B8001|Y|000|Success|BILLERDETAILRFAGNT178316690602|YS01|C1001|{\"billerId\":\"BESCOM000KAR02\",\"billerName\":\"Bangalore Electricity Supply Co. Ltd (BESCOM)\",\"billerAliasName\":null,\"billerCategoryName\":\"Electricity\",\"billerMode\":\"ONLINE\",\"billerAcceptsAdhoc\":false,\"parentBiller\":false,\"parentBillerId\":null,\"billerOwnerShp\":\"PSU\",\"billerCoverage\":\"IND-KAR\",\"fetchRequirement\":\"MANDATORY\",\"paymentAmountExactness\":\"Exact and above\",\"supportBillValidation\":\"NOT_SUPPORTED\",\"billerEffctvFrom\":\"2018-03-02\",\"billerEffctvTo\":\"2025-12-31\",\"billerTempDeactivationStart\":null,\"billerTempDeactivationEnd\":null,\"billerPaymentModes\":[{\"paymentMode\":\"Internet Banking\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Debit Card\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Credit Card\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Prepaid Card\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"IMPS\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Cash\",\"maxLimit\":4999900,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"UPI\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Wallet\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"NEFT\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"AEPS\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"},{\"paymentMode\":\"Account Transfer\",\"maxLimit\":0,\"minLimit\":1,\"supportPendingStatus\":\"No\"}],\"billerPaymentChannels\":[{\"paymentChannel\":\"INT\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"INTB\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"MOB\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"MOBB\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"POS\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"MPOS\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"ATM\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"BNKBRNCH\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"KIOSK\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"AGT\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"},{\"paymentChannel\":\"BSC\",\"maxLimit\":500000000,\"minLimit\":100,\"supportPendingStatus\":\"No\"}],\"billerCustomerParams\":[{\"paramName\":\"Customer ID / Account ID\",\"dataType\":\"NUMERIC\",\"optional\":false,\"minLength\":1,\"maxLength\":10,\"regex\":null}],\"billerResponseParams\":{\"params\":[],\"amountOptions\":[{\"amountBreakupSet\":[\"BASE_BILL_AMOUNT\"]}]},\"billerAdditionalInfo\":[],\"interchangeFeeConf\":[{\"mti\":\"PAYMENT\",\"paymentMode\":null,\"paymentChannel\":null,\"responseCode\":\"000\",\"fees\":[\"CCF1\",\"EBF\"],\"defaultFee\":true,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null},{\"mti\":\"PAYMENT\",\"paymentMode\":null,\"paymentChannel\":\"BNKBRNCH\",\"responseCode\":\"000\",\"fees\":[\"CCF1\",\"PBF\"],\"defaultFee\":false,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null},{\"mti\":\"PAYMENT\",\"paymentMode\":null,\"paymentChannel\":\"AGT\",\"responseCode\":\"000\",\"fees\":[\"CCF1\",\"PBF\"],\"defaultFee\":false,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null},{\"mti\":\"PAYMENT\",\"paymentMode\":null,\"paymentChannel\":\"BSC\",\"responseCode\":\"000\",\"fees\":[\"CCF1\",\"PBF\"],\"defaultFee\":false,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null}],\"interchangeFee\":[{\"feeCode\":\"CCF1\",\"feeDesc\":\"Customer_Convenience_Fee\",\"feeDirection\":\"C_2_B\",\"interchangeFeeDetails\":[{\"tranAmtRangeMax\":9223372036854775807,\"tranAmtRangeMin\":0,\"percentFee\":0,\"flatFee\":0,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null}]},{\"feeCode\":\"PBF\",\"feeDesc\":\"Physical_Biller_Fee\",\"feeDirection\":\"B_2_C\",\"interchangeFeeDetails\":[{\"tranAmtRangeMax\":9223372036854775807,\"tranAmtRangeMin\":0,\"percentFee\":0,\"flatFee\":225,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null}]},{\"feeCode\":\"EBF\",\"feeDesc\":\"Electronic_Biller_Fee\",\"feeDirection\":\"B_2_C\",\"interchangeFeeDetails\":[{\"tranAmtRangeMax\":9223372036854775807,\"tranAmtRangeMin\":0,\"percentFee\":0,\"flatFee\":225,\"effctvFrom\":\"2019-06-22\",\"effctvTo\":null}]}],\"status\":\"A\",\"billerDescription\":null,\"supportDeemed\":null,\"supportPendingStatus\":null,\"billerTimeOut\":null}|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA",
          failure: "B7001|N|001|Failure"
      }
  )

  # Message Code (B8000)| Ref No| Agent institution Id |Channel Id| Biller Id| Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :biller_id,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  # Message Code(B8001) |Status |Error Code |Error Desc |Ref No |Agent Institution Id |Channel Id| [Biller Details in JSON format]|Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15| Additional Field 15
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id,
          :channel_id, :biller_details,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  def biller_id
    params[:biller_id]
  end

  def self.handle_success(result)
    OpenStruct.new(JSON.parse(result['response.parsed']['biller_details']))
  end

end