class Bbps::BillerDetails < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
    end
  end

  setup_defaults
  path "getBillerDetails"

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
    OpenStruct.new(JSON.parse(result['response.parsed']['biller_details']))
  end

end