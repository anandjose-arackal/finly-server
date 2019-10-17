class Bbps::BillerDetails < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
    end
  end

  setup_defaults
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
    'B7000' # Todo - Correct code as per documentation is B8000 but B7000 is what is working on UAT
  end

  def biller_id
    params[:biller_id]
  end

  def self.handle_success(result)
    data = JSON.parse(result['response.parsed']['biller_details'])
    format(data)
  end

  # The JSON response has a pipe delimiter in the biller_details. Hence, handling it correctly
  def parse_response(user, params, response)
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    map = {}.with_indifferent_access

    # Map till channel id
    response_fields = fetch(:response_fields)
    response_fields[0..6].each_with_index { |field, index| map[field] = splits[index] }

    map[:biller_details] = response_fields[7..response_fields.size-15].join("|")
    map
  end

end