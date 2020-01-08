class Bbps::BillersList < Bbps::Api

  schema do
    params do
      # required(:category).filled
    end
  end

  path "getBillerList"
  parse -> (user, params, response) { parse_json_response(:billers_list, user, params, response) }

  # Message Code(B7000)|RefNo | Agent Institution Id| Channel Id| Category |Last Updated Timestamp|AdditionalField1|Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  # Example: B7000|M3TEST8976543|YS01|C1001|Mobile|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :category, :last_updated_timestamp,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  # Message Code(B7001) |Status |Error Code |Error Desc | Ref No | Agent Institution Id |Channel Id| [List of BillerId, Biller Name and Category in JSON format]|Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14|Additional Field 15
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id,
          :channel_id, :billers_list,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  def message_code
    'B7000'
  end

  def category
    params[:category]
  end

  def self.handle_success(result)
    list = JSON.parse(result['response.parsed']['billers_list'])
    list.map { |item| format(item) }
  end

  def self.handle_error(data)
    data
  end

end