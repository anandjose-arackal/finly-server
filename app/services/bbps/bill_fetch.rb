class Bbps::BillFetch < Bbps::Api

  schema do
    params do
      # Todo filled from user
      # optional(:customer_name).filled
      # required(:customer_mobile).filled
      # optional(:customer_email).filled
      # optional(:customer_aadhar_no).filled
      # optional(:customer_pan_id).filled

      # Todo fill from request
      # required(:initiating_channel).filled

      required(:biller_id).filled
      required(:customer_param_1).filled # Atleast one param is required
      optional(:customer_param_2).filled
      optional(:customer_param_3).filled
      optional(:customer_param_4).filled
      optional(:customer_param_5).filled
    end
  end

  setup_defaults
  path "billFetch"
  dummy_response(
      {
          success: "B1001|Y|000|Successful|FETCHREFAGENTE6A41816295711001|YS01|C1001|FETCHREF AGENTE6A41816295711001FETCH|YS01AB21000001123458|Manoj Chekuri|9012345001|mk.chekuri@gmail.com|NA|BXXCG7754K|BSC|TSTO00000NAT01|2 00|2017-06-01|2017-06-30|123450001|June|NA|NA|Early Payment Amount=100|Late Payment Amount=300|NA|NA|NA|NA|NA|NA",
          failure: "B7001|N|001|Failure"
      }
  )

  # Message Code(B1000)|Ref No |Agent Institution Id|Channel Id |AgentId |Customer name |Customer mobile |Customer email |Customer Aadhar No |Customer PAN id |
  #   INITIATING_CHANNEL:
  # <MOBILE=?~GEOCODE=?~POSTAL_CODE=?~IP=?~TERMINAL_I
  #  D=?~IMEI=?~IFSC=?~MAC=?~OS=?~APP=?>|Biller ID | CustomerParam1Name=CustomerParam1Value| CustParam2Name= CustParam2Value|
  #  CustParam3Name= CustParam3Value | CustParam4Name= CustParam4Value | CustParam5Name= CustParam5Value |Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6 | Additional Field 7| Additional Field 8| Additional Field 9 |Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  #
  # Example: B1000|FETCHREFAGENTE6A41816295711001|YS01|C1001|18800|Riyaz|9012345001|mk.ch ekuri@gmail.com|NA|BXXCG7754K|BSC:<TERMINAL_ID=18796~MOBILE=9505987798~GE OCODE=22.5726,88.3639~POSTAL_CODE=700017>|TSTO00000NAT01|Customer Reference Field1=10|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA |NA|NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :agent_id, :customer_name, :customer_mobile,
          :customer_email, :customer_aadhar_no, :customer_pan_id, :initiating_channel, :biller_id, :customer_param_1, :customer_param_2,
          :customer_param_3, :customer_param_4, :customer_param_5,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  # Message Code(B1001) |Status |Error Code |Error Desc | Ref No | Agent institution Id | Channel Id| BBPS Ref Id |Agent Id | Customer name |
  # Customer mobile |Customer email |Customer Aadhar No |Customer PAN id |Channel |Biller ID |
  # Amount |Bill Date |Due Date |Bill Number |Bill Period |Convenience Fee |
  # Convenience Fee Desc |Late Payment Fee |Early payment Fee |
  # Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6
  #
  # Example:
  # B1001|Y|000|Successful|M3TESTFETCH56432|YS01|C1001|M3TESTFETCH56432FETCHREF11192729081|YS01YS01510347123456|
  # BBPS|8484943085|NA|NA|NA|BSC|OFME00005DNZ43|100000|2015-06-14|2015-06-20|12303|june|NA|NA|
  # Late Payment Fee=40|Fixed Charges=50|Additional Charges=60|a=10|a b=20|a b c=30|12345678|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id, :channel_id,
          :bbps_ref_id, :agent_id, :customer_name, :customer_mobile, :customer_email, :customer_aadhar_no, :customer_pan_id,
          :channel_id, :biller_id, :amount, :bill_date, :due_date, :bill_number, :bill_period, :convenience_fee,
          :convenience_fee_desc, :late_payment_fee, :early_payment_fee,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field
      ]
  )

  def customer_name
    user.company&.name
  end

  def customer_mobile
    user.mobile_number
  end

  def customer_email
    user.email
  end

  # def customer_aadhar_no
  #   params[:customer_aadhar_no]
  # end
  #
  # def customer_pan_id
  #   params[:customer_pan_id]
  # end

  def biller_id
    params[:biller_id]
  end

  def initiating_channel
    "BSC:<>"
  end

  def customer_param_for(param)
    return "NA" if params[param].blank?

    "#{params[param][:key]}=#{params[param][:value]}"
  end

  def customer_param_1
    customer_param_for(:customer_param_1)
  end

  def customer_param_2
    customer_param_for(:customer_param_2)
  end

  def customer_param_3
    customer_param_for(:customer_param_3)
  end

  def customer_param_4
    customer_param_for(:customer_param_4)
  end

  def customer_param_5
    customer_param_for(:customer_param_5)
  end

  def self.handle_success(result)
    # customer_bbps_name, :amount, :bill_date, :due_date, :bill_number, :bill_period, :convenience_fee,
    # :convenience_fee_desc, :late_payment_fee, :early_payment_fee
    OpenStruct.new(
        {
            amount: result['response.parsed']['amount'],
            bill_date: result['response.parsed']['bill_date'],
            due_date: result['response.parsed']['due_date'],
            bill_number: result['response.parsed']['bill_number'],
            bill_period: result['response.parsed']['bill_period'],
            convenience_fee: result['response.parsed']['convenience_fee'],
            convenience_fee_desc: result['response.parsed']['convenience_fee_desc'],
            late_payment_fee: result['response.parsed']['late_payment_fee'],
            early_payment_fee: result['response.parsed']['early_payment_fee'],
        }
    )
  end

end