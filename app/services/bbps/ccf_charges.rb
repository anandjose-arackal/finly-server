class Bbps::CCFCharges < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
      required(:amount).filled
    end
  end

  setup_defaults
  path "billFetch"
  dummy_response(
      {
          success: "B3001|Y|000|Success|GICCFRN911EVM20009300421129116|YS01|C1001|0|0|200|0|0|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA",
          failure: "B7001|N|001|Failure"
      }
  )

  # Message Code (B3000)| Ref No| Agent institution Id |Channel Id| Biller Id| Amount |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :biller_id, :amount,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  # Message Code(B3001) |Status |Error Code |Error Desc |Ref No |Agent Institution Id |Channel Id| Customer Conv. Fee | Service Tax | Amount |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15| Additional Field 15
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id,
          :cust_conv_fee, :service_tax, :amount,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field
      ]
  )

  def biller_id
    params[:biller_id]
  end

  def amount
    params[:amount]
  end

  def self.handle_success(result)
    OpenStruct.new(
        {
            cust_conv_fee: result['response.parsed']['cust_conv_fee'],
            service_tax: result['response.parsed']['service_tax'],
            amount: result['response.parsed']['amount'],
        }
    )
  end

end