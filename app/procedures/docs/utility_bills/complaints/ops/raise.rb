class Docs::UtilityBills::Complaints::Ops::Raise < Transactions::API

  schema do
    params do
      required(:mobile_number).filled
      required(:complaint_type).filled
      required(:complaint_category).filled
      required(:complaint_entity_id).filled
    end
  end

  step :init

  def init(options, params:, **)
    Bbps::ComplaintCreate.(params, "current_user" => User.first) do |op|
      op.success do |op_result|
        result = {
            'complaints' => op_result
        }

        options['result'] = result
      end

      op.failure do |op_result|
        # todo - Remove below code
        response = {"TxnStatusComplainResp" => {"txnList": nil, "customerDetails": nil, "msgId": "COMPLAINTMSGC13A3484AE2170627110227", "complaintId" => "DQ1498541548003", "openComplaint": nil, "complaintStatus": nil, "assigned": "XYZ Bank", "responseCode": "000", "responseReason": "SUCCESS"}}
        data = {
            'complaint_id': response["TxnStatusComplainResp"]["complaintId"],
            'complaint_details' => response
        }
        result = data
        options['result'] = result
        # Send error response
      end
    end
  end
end