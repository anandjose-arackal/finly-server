class Bbps::BillerDetails < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
    end
  end

  path "getBillerDetails"
  parse -> (user, params, response) { parse_json_response(:biller_details, user, params, response) }

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

  def message_code
    'B8000' # Todo - Correct code as per documentation is B8000 but B7000 is what is working on UAT
  end

  def biller_id
    params[:biller_id]
  end

  # The JSON response has a pipe delimiter in the biller_details. Hence, handling it correctly
  def parse_json_response(json_key, user, params, response)
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    # Request failed
    return Failure((splits[3] || 'Unable to fetch response')) if splits[1] == 'N'
    return Failure('Biller not found') if splits[7].starts_with?('No Biller Found with ID')

    map = {}.with_indifferent_access

    # Map till channel id
    response_fields = fetch(:response_fields)
    json_key_index = response_fields.find_index(json_key)
    start_index = json_key_index
    end_index = splits.size - (response_fields.size - json_key_index)
    # 0 to json_key
    response_fields.first(start_index).each_with_index { |field, index| map[field] = splits[index] }

    # Json key
    map[json_key] = splits[start_index..end_index].join("|")

    # JSON Key to end
    ending_splits = splits.last(end_index)
    response_fields.last(response_fields.size - json_key_index - 1).each_with_index { |field, index| map[field] = ending_splits[index] }
    map
  end

  def self.handle_success(result)
    data = JSON.parse(result['response.parsed']['biller_details'])
    format(data)
  end

end