class Bbps::ComplaintCreate < Bbps::Api

  # Todo
  #
  schema do
    params do
      required(:mobile_number).filled
      required(:complaint_type).filled
      required(:complaint_category).filled
      required(:complaint_entity_id).filled
      optional(:description).filled
        # optional(:ref_id).filled
        # optional(:txn_ref_id).filled
    end
  end
  #
  # setup_defaults
  path "raiseComplaint"

  # # Message Code(B5000)| Ref No |Agent institution Id | Channel Id| Agent Id |
  # # Complaint Category |Compliant type| Complaint Entity ID |Description |
  # # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5|
  # # Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10|
  # # Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15|
  # # Ref ID| Txn Ref ID
  # #
  # # Example:
  # # B9000 |COMPLNLSTREFAGENT171308183209|YS01 |C1001 | 18799|9699381878| NA |NA |NA |NA |NA |NA |NA |NA |NA |NA|NA|NA|NA|NA|NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :agent_id,
          :complaint_category, :complaint_type, :complaint_entity_id, :description,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :ref_id, :txn_ref_id
      ]
  )

  # Message Code(B5001)|Status |Error Code |Error Desc| Ref No| Agent institution Id | Channel Id |Agent Id |
  # Complaint Id|Mobile Number| {Response Data in Json format}|Additional Field 1| Additional Field 2| Additional Field 3|
  # Additional Field 4| Additional Field 5| Additional Field 6| Additional Field 7| Additional Field 8|
  # Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13|
  # Additional Field 14| Additional Field 15
  # # Example: B9001|Y|000|Success|COMPLNLSTREFAGENT171308183209|YS01AB21000001123123|C100 1|[]|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_number, :agent_institution_id, :channel_id, :agent_id,
          :complaint_id, :mobile_number, :complaint_data,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )
  #
  def message_code
    'B5000'
  end

  def complaint_category
    params[:complaint_category]
  end

  def complaint_type
    params[:complaint_type]
  end

  def complaint_entity_id
    params[:complaint_entity_id]
  end

  def description
    params[:description]
  end

  def ref_id
    params[:ref_id]
  end

  def txn_ref_id
    params[:txn_ref_id]
  end

  #
  def customer_mobile
    params[:mobile_number]
  end

  #
  def self.handle_success(result)
    # todo - Uncomment Real Data
    # data = {
    #     complaint_id: result['response.parsed']['TxnStatusComplainResp']['complainId'],
    #     complaint_details: JSON.parse(result['response.parsed']['complaint_data'])
    # }

    # todo - Comment / Remove junk response
    response = {"TxnStatusComplainResp": {"txnList": nil, "customerDetails": nil, "msgId": "COMPLAINTMSGC13A3484AE2170627110227", "complaintId": "DQ1498541548003", "openComplaint": nil, "complaintStatus": nil, "assigned": "XYZ Bank", "responseCode": "000", "responseReason": "SUCCESS"}}
    data = {
        complain_id: response["TxnStatusComplainResp"]["complainId"],
        complain_details: response
    }
    OpenStruct.new data
  end

  def self.handle_error(data)
    data
  end

end