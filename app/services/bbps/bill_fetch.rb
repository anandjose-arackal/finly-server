class Bbps::BillFetch < Bbps::Api


  schema do 
    params do
      # Todo filled from user
      optional(:customer_name).filled
      required(:mobile_number).filled
      optional(:email).filled
      optional(:aadhar_no).filled
      optional(:pan_id).filled

      # Todo fill from request
      # required(:initiating_channel).filled

      required(:biller_id).filled
      # Atleast one param is required
      required(:customer_param_1) do
        hash do
          required(:key).filled
          required(:value).filled
        end
      end
      optional(:customer_param_2) do
        hash do
          required(:key).filled
          required(:value).filled
        end
      end
      optional(:customer_param_3) do 
        hash do
          required(:key).filled
          required(:value).filled
        end
      end
      optional(:customer_param_4) do
        hash do
          required(:key).filled
          required(:value).filled
        end
      end
      optional(:customer_param_5) do
        hash do
          required(:key).filled
          required(:value).filled
        end
      end
    end
  end

  path 'fetch'
  url 'https://yesbbps.transxt.in:9443/portal/service/npciservice'
  header "AUTH","/WT/ijy7z5abJBM/LAwbmA=="

  def body
    message = generate_message
    Rails.logger.info("Raw message :: #{message}")
    encoded_message = Base64.strict_encode64(message)
    encrypted_message = encrypt(encoded_message)
    Rails.logger.info("Encrypted message :: #{encrypted_message}")
    body = {request: encrypted_message}
    log_generator.merge({request_raw_message: message})
    body
  end

  def self.build_matcher(options, result)
    Dry::Matcher.new(
        success: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Success", result; result['response.parsed']&.dig('status') == 'SUCCESS'},
            resolve: -> (result) { handle_success(result) }
        ),
        error: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Error", result; result['response.parsed']&.dig('status') == 'FAILURE'},
            resolve: -> (result) { handle_error(result['response.parsed']) }
        ),
        failure: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Failure", result; true},
            resolve: -> (result) {result}
        )
    )
  end

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

  # 1:message_code, 2:ref_number, 3:agent_institution_id, 4:channel_id, 5:agent_id, 6:customer_name, 7:customer_mobile,
  # 8:customer_email, 9:customer_aadhar_no, 10:customer_pan_id, 11:initiating_channel, 12:biller_id, 13:customer_param_1, 14:customer_param_2,
  # 15:customer_param_3, 16:customer_param_4, 17:customer_param_5,
  # 18:additional_field, 19:additional_field, 20:additional_field, 21:additional_field, 22:additional_field,
  # 23:additional_field, 24:additional_field, 25:additional_field, 26:additional_field, 27:additional_field,
  # 28:additional_field, 29:additional_field, 30:additional_field, 31:additional_field, 32:additional_field

  # 1:B1000|2:1533109635610|3:YS01|4:C1001|5:18798|6:NA|7:8484943085|
  # 8:NA|9:NA|10:NA|11:BSC:<TERMINAL_ID=18798~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>|12:OFME00005DNZ43|13:a=10|14:a b=20|
  # 15:a b c=30|16:a b c d=40|17:a b c d e=50|
  # 18:NA|19:NA|20:NA|21:NA|22:NA|
  # 23:NA|24:NA|25:NA|26:NA|27:NA|
  # 28:NA|29:NA|30:NA|31:Y|32:0
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
          :additional_field_1, :additional_field_2, :additional_field_3, :additional_field_4, :additional_field_5,
          :additional_field_6
      ]
  )

  def message_code
    'B1000'
  end

  def customer_name
    params[:customer_name]
  end

  def customer_mobile
    params[:mobile_number]
  end

  def customer_email
    params[:email]
  end

  def customer_aadhar_no
    params[:aadhar_no]
  end

  def customer_pan_id
    params[:pan_id]
  end

  def biller_id
    params[:biller_id]
  end

  def initiating_channel
    # "Mobile Banking (Pre-Login)"
    # "MOB:<IP=13.126.31.9~IMEI=1234~OS=Android~APP=Finly>"
    "MOB:<IP=13.232.176.84~IMEI=1234~OS=Android~APP=Finly>"
    # "BSC:<TERMINAL_ID=1042~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>"
    # "BSC:<TERMINAL_ID=1042~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>"
    # BGP : 13.232.176.84
    # UAT : 13.126.31.9
    # "INTB:<IP=13.126.31.9~MAC=02:ca:d0:16:ce:60:00:00:00:00:00:00>"
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
    #  "message_code" => "B1001",
    #                   "status" => "Y",
    #               "error_code" => "000",
    #               "error_desc" => "Successful",
    #                   "ref_no" => "R24121911254444851",
    #     "agent_institution_id" => "YB28",
    #               "channel_id" => "BSC",
    #              "bbps_ref_id" => "R24121911254444851FETCHREF165545241",
    #                 "agent_id" => "YB01YB28BSC528205568",
    #            "customer_name" => "REENA RANI",
    #          "customer_mobile" => "7406032047",
    #           "customer_email" => "NA",
    #       "customer_aadhar_no" => "NA",
    #          "customer_pan_id" => "NA",
    #                "biller_id" => "BSESYAMPLDEL01",
    #                   "amount" => "2000",
    #                "bill_date" => "2019-12-20",
    #                 "due_date" => "2020-01-07",
    #              "bill_number" => "151191591",
    #              "bill_period" => "DECEMBER",
    #          "convenience_fee" => "NA",
    #     "convenience_fee_desc" => "NA",
    #         "late_payment_fee" => "NA",
    #        "early_payment_fee" => "NA",
    #         "additional_field" => "NA"
    OpenStruct.new(
      {
          # Add Order ID
        amount: result['response.parsed']['amount'],
        status: 'Y',
        bill_date: result['response.parsed']['bill_date'],
        due_date: result['response.parsed']['due_date'],
        bill_number: result['response.parsed']['bill_number'],
        bill_period: result['response.parsed']['bill_period'],
        biller_id: result['response.parsed']['biller_id'],
        convenience_fee: result['response.parsed']['convenience_fee'],
        convenience_fee_desc: result['response.parsed']['convenience_fee_desc'],
        late_payment_fee: result['response.parsed']['late_payment_fee'],
        early_payment_fee: result['response.parsed']['early_payment_fee'],
        error_code: result['response.parsed']['error_code'],
        error_desc: result['response.parsed']['error_desc'],
        ref_no: result['response.parsed']['ref_no'],
        agent_institution_id: result['response.parsed']['agent_institution_id'],
        channel_id: result['response.parsed']['channel_id'],
        channel: result['response.parsed']['channel'],
        bbps_ref_id: result['response.parsed']['bbps_ref_id'],
        agent_id: result['response.parsed']['agent_id'],
        customer_name: result['response.parsed']['customer_name'],
        customer_mobile: result['response.parsed']['customer_mobile'],
        customer_email: result['response.parsed']['customer_email'],
        customer_aadhar_no: result['response.parsed']['customer_aadhar_no'],
        customer_pan_id: result['response.parsed']['customer_pan_id'],
        additional_field_1: result['response.parsed']['additional_field_1'],
        additional_field_2: result['response.parsed']['additional_field_2'],
        additional_field_3: result['response.parsed']['additional_field_3'],
        additional_field_4: result['response.parsed']['additional_field_4'],
        additional_field_5: result['response.parsed']['additional_field_5'],
        additional_field_6: result['response.parsed']['additional_field_6']
      }
    )
  end

  def self.handle_error(result)
    OpenStruct.new(
      {
        status: 'N',
        error_code: result['error_code'],
        error_desc: result['error_desc'],
        ref_no: result['ref_no']
      }
    )
  end

  def generate_message
    message = {}
    message["custDetails"] = {}
    message["custDetails"]["mobileNo"] = customer_mobile
    message["custDetails"]["customerTags"] = []
    message["custDetails"]["customerTags"] << {"name"=> "EMAIL", "value"=> customer_email} if customer_email.present?
    message["custDetails"]["customerTags"] << {"name"=> "AADHAAR", "value"=> customer_aadhar_no} if customer_aadhar_no.present?
    message["custDetails"]["customerTags"] << {"name"=> "PAN", "value"=> customer_pan_id} if customer_pan_id.present?
    message["agentDetails"] = {}
    message["agentDetails"]["agentId"] = "YB01YB28MOB519101711"
    message["agentDetails"]["deviceTags"] = []
    message["agentDetails"]["deviceTags"] << { "name" => "IP", "value" => "13.232.176.84" }
    message["agentDetails"]["deviceTags"] << { "name" => "IMEI", "value" => "1234" }
    message["agentDetails"]["deviceTags"] << { "name" => "OS", "value" => "Android" }
    message["agentDetails"]["deviceTags"] << { "name" => "APP", "value" => "FINLY" }
    message["agentDetails"]["deviceTags"] << { "name" => "INITIATING_CHANNEL", "value" => "MOB" }
    message["billDetails"] = {}
    message["billDetails"]["billerId"] = biller_id
    message["billDetails"]["customerParams"] = []
    (1..5).to_a.each do |i|
      value = self.send("customer_param_#{i}")
      customer_param_message = value.split('=')
      if value.present? && value!= "NA"
        message["billDetails"]["customerParams"] << { "name"=>customer_param_message[0], "value"=> customer_param_message[1]}
      end
    end
    message.to_json
  end

  def parse_response(user, params, response)
    received_response = JSON.parse(response.body)
    parsed_response = {}
    return Failure("Invalid response") unless response.status == 200
    return Failure("Invalid response") unless received_response&.dig("response").present?

    parsed_response["error_code"] = received_response["response"]["complianceRespCd"]
    parsed_response["error_desc"] = received_response["response"]["complianceReason"]

    parsed_response["status"] = received_response["status"]
    parsed_response["bbps_ref_id"] = received_response["response"]["refId"]
    parsed_response["responseCode"] = received_response["response"]["responseCode"]
    parsed_response["amount"] = received_response["response"]["billerResponse"]["amount"]
    parsed_response["due_date"] = received_response["response"]["billerResponse"]["dueDate"]
    parsed_response["bill_date"] = received_response["response"]["billerResponse"]["billDate"]
    parsed_response["bill_period"] = received_response["response"]["billerResponse"]["billPeriod"]
    parsed_response["amount"] = received_response["response"]["billerResponse"]["amount"]
    parsed_response["bill_date"] = received_response["response"]["txnDateTime"]
    parsed_response["bill_number"] = received_response["response"]["billNumber"]
    parsed_response["convenience_fee"] = received_response["response"]["billerResponse"]["CustConvFee"]
    parsed_response["convenience_fee_desc"] = received_response["response"]["billerResponse"]["CustConvDesc"]
    parsed_response["biller_id"] = received_response["response"]["billDetails"]["billerId"]

    parsed_response["customer_name"] = received_response["response"]["billerResponse"]["customerName"]
    parsed_response["customer_email"] = received_response["response"]["billerResponse"]["customerEmail"]
    parsed_response["customer_aadhar_no"] = received_response["response"]["billerResponse"]["customerAadhar"]

    #map customer params?
    # if received_response["response"]["additionalInfo"].present? && 
    #   received_response["response"]["additionalInfo"].each_with_index do |add_info, index|
    #     parsed_response["addition_info_#{index}"] = add_info
    #   end
    # end
    parsed_response
  end

end
