class Bbps::ComplaintStatus < Bbps::Api
  schema do
    params do
      required(:complaint_id).filled
    end
  end
  #
  # setup_defaults
  path "getComplaintStatus"

  # Message Code(B6000)| Ref No |Agent institution Id | Channel Id| Agent Id | Complaint Id |
  # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5| Additional Field 6|
  # Additional Field 7| Additional Field 8| Additional Field 9|Additional Field 10| Additional Field 11| Additional Field 12|
  # Additional Field 13| Additional Field 14 | Additional Field 15 | Ref ID | Txn Ref ID
  # # Example:
  # B6000 |COMPLNLSTREFAGENT178388153208|YS01|C1001|18800 |QB1474357630126| S |NA |NA |NA |NA |NA |NA |NA |NA |NA|NA|NA|NA|NA|NA|NA|NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :agent_id, :complaint_id,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :ref_id, :txn_ref_id
      ]
  )
  #
  # Message Code(B6001)|Status |Error Code |Error Desc |Ref No|Agent institution Id | Channel ID| Agent Id | {Complaint details in Json format}|
  # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5| Additional Field 6|
  # Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12|
  # Additional Field 13| Additional Field 14| Additional Field 15

  #   B6001|Y|000|Success|COMPLNLSTREFAGENT178388153208|YS01|C1001|YS01AB21000001
  #   123458|{\"TxnStatusComplainResp\":
  # {\"txnList\":null,\"customerDetails\":null,\"msgId\":\"COMPLAINTMSG62790CF4A08170627
  # 105502\",\"complaintId\":\"QB1474357630126\",\"openComplaint\":null,\"complaintStatus\":null,\"assigned\":null,\"responseCode\":\"001\",\"responseReason\":\"Complaint not
  # found\"}}|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA

  # # Example: B9001|Y|000|Success|COMPLNLSTREFAGENT171308183209|YS01AB21000001123123|C100 1|[]|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_number, :agent_institution_id, :channel_id, :complaint_details,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )
  #
  def message_code
    'B6000'
  end

  def complaint_id
    params[:complaint_id]
  end
  #
  # def customer_mobile
  #   params[:mobile_number]
  # end
  #
  # def self.handle_success(result)
  #   list = JSON.parse(result['response.parsed']['complaint_list'])
  #   list.map { |item| OpenStruct.new(item) }
  # end
  def self.handle_success(result)
    complaint_details = JSON.parse result['response.parsed']['complaint_details']
    OpenStruct.new complaint_details
  end

end