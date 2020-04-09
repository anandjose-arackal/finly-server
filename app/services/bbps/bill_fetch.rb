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

  path "billFetch"

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
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field
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
            status: result['response.parsed']['status'],
            bill_date: result['response.parsed']['bill_date'],
            due_date: result['response.parsed']['due_date'],
            bill_number: result['response.parsed']['bill_number'],
            bill_period: result['response.parsed']['bill_period'],
            convenience_fee: result['response.parsed']['convenience_fee'],
            convenience_fee_desc: result['response.parsed']['convenience_fee_desc'],
            late_payment_fee: result['response.parsed']['late_payment_fee'],
            early_payment_fee: result['response.parsed']['early_payment_fee'],
            error_code: result['response.parsed']['error_code'],
            error_desc: result['response.parsed']['error_desc'],
            ref_no: result['response.parsed']['ref_no'],
            agent_institution_id: result['response.parsed']['agent_institution_id'],
            channel_id: result['response.parsed']['channel_id'],
            bbps_ref_id: result['response.parsed']['bbps_ref_id'],
            agent_id: result['response.parsed']['agent_id'],
            customer_name: result['response.parsed']['customer_name'],
            customer_mobile: result['response.parsed']['customer_mobile'],
            customer_email: result['response.parsed']['customer_email'],
            customer_aadhar_no: result['response.parsed']['customer_aadhar_no'],
            customer_pan_id: result['response.parsed']['customer_pan_id']
        }
    )
  end

  def self.handle_error(data)
    data
  end
end