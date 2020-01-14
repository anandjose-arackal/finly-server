class Bbps::ComplaintList < Bbps::Api

  schema do
    params do
      required(:mobile_number).filled
    end
  end

  path "getComplaintList"

  # Message Code(B9000)| Ref No |Agent institution Id | Channel Id| Agent Id | Mobile No |
  # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5|
  # Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10|
  # Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  #
  # Example:
  # B9000 |COMPLNLSTREFAGENT171308183209|YS01 |C1001 | 18799|9699381878| NA |NA |NA |NA |NA |NA |NA |NA |NA |NA|NA|NA|NA|NA|NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :agent_id,
          :customer_mobile,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )

  # Message Code(B9001)|Status |Error Code |Error Desc | Ref No|Agent institution Id | Channel ID| Agent Id | Response Data in Json format|
  # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5
  #
  # Example: B9001|Y|000|Success|COMPLNLSTREFAGENT171308183209|YS01AB21000001123123|C100 1|[]|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_number, :agent_institution_id, :channel_id,
          :complaint_list,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )

  def message_code
    'B9000'
  end

  def customer_mobile
    params[:mobile_number]
  end

  def self.handle_success(result)
    list = JSON.parse(result['response.parsed']['complaint_list'])
    list.map { |item| OpenStruct.new(item) }
  end

  def self.handle_error(data)
    data
  end

end