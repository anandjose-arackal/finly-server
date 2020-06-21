class Bbps::BillPay < Bbps::Api

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

      required(:amount).filled
      required(:bill_date).filled
      required(:due_date).filled
      required(:bill_number).filled
      required(:bill_period).filled
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

  path "billPay"

  # Message Code(B2000) | Order No |Agent institution Id |Channel Id |Agent Id |
  # Quick Pay |Split Pay |Split Pay Amt |Customer name|Customermobile|
  # Customeremail|CustomerAadhar No |Customer PAN id |Amount |Bill Date |
  # Due Date |Bill Number |Bill Period |Convenience Fee |
  # Convenience Fee Desc|
  # INITIATING_CHANNEL: <MOBILE=?~GEOCODE=?~POSTAL_CODE=?~IP=?~TERMINAL_ID=?~IMEI=?~IFSC=?~MAC=?~OS=?~APP=?>|
  # PaymentMode:<Remarks=? or CardNum~AuthCode or IFSC~AccountNo or MMID~MobileNo or WalletName~MobileNo or VPA>|
  # Debit Account Number |Biller ID | CustomerParam1Name=CustomerParam1Value| CustParam2Name= CustParam2Value|
  # CustParam3Name= CustParam3Value | CustParam4Name= CustParam4Value | CustParam5Name= CustParam5Value|
  # Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5|
  # Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10|
  # Additional Field 11| Additional Field 12| Additional Field 13| ON-US/OFF-US FLAG | CCF2 Charges
  #
  #

  # Example: B2000|ASD1503901571142|YS01|C1001|18796|Y|N|0|NA|9898990091|mk.chekuri@gmail.com|NA|
  # BXXCG7754K|200|NA|NA|NA|NA|0|NA|
  # BSC:<TERMINAL_ID=18800~MOBIL E=9505987798~GEOCODE=22.5726,88.3639~POSTAL_CODE=700017>|Cash:<Remarks=123456 >|
  # 003693600003383|TSTP00000TMN02|Customer Reference Field1=10|
  # Customer Reference Field2=20|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|Y|0
  request_fields(
      [
        :message_code, :order_number, :agent_institution_id, :channel_id, :agent_id,
        :quick_pay,:split_pay, :split_pay_amount, :customer_name, :customer_mobile,
        :customer_email, :customer_aadhar_no, :customer_pan_id,
        :amount, :bill_date, :due_date, :bill_number, :bill_period,
        :convenience_fee, :convenience_fee_desc,
        :initiating_channel, :payment_mode, :debit_account_number, :biller_id,
        :customer_param_1, :customer_param_2, :customer_param_3, :customer_param_4, :customer_param_5,
        :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
        :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
        :additional_field, :additional_field, :additional_field, :on_us_off_us, :ccf_charges
      ]

  # 1:message_code, 2:order_number, 3:agent_institution_id, 4:channel_id, 5:agent_id,
  # 6:quick_pay,7:split_pay, 8:split_pay_amount, 9:customer_name, 10:customer_mobile,
  # 11:customer_email, 12:customer_aadhar_no, 13:customer_pan_id,
  # 14:amount, 15:bill_date, 16:due_date, 17:bill_number, 18:bill_period,
  # 19:convenience_fee, 20:convenience_fee_desc,
  # 21:initiating_channel, 22:payment_mode, 23:debit_account_number, 24:biller_id,
  # 25:customer_param_1, 26:customer_param_2, 27:customer_param_3, 28:customer_param_4, 29:customer_param_5,
  # 30:additional_field, 31:additional_field, 32:additional_field, 33:additional_field, 34:additional_field,
  # 35:additional_field, 36:additional_field, 37:additional_field, 38:additional_field, 39:additional_field,
  # 40:additional_field, 41:additional_field, 42:additional_field, 43:on_us_off_us, 44:ccf_charges

  # WORKING SAMPLE
  # 1:B2000|2:kailas33571000018889w29298|3:YS01|4:C1001|5:18798|
  # 6:N|7:N|8:0|9:BBPS|10:8484943085|
  # 11:NA|12:NA|13:NA|
  # 14:90000|15:2015-06-14|16:2015-06-20|17:12303|18:june|
  # 19:0|20:Service Tax|
  # 21:BSC:<TERMINAL_ID=18798~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>|22:Cash:<Remarks=Test1>|23:006290100012468|24:OFME00005DNZ43|
  # 25:a=10|26:a b=20|27:a b c=30|28:a b c d=40|29:a b c d e=50|
  # 30:NA|31:NA|32:NA|33:NA|34:NA|35:NA|36:NA|37:NA|38:NA|39:NA|40:NA|41:NA|42:NA|43:Y|44:0

  # QUICK PAY
  # 1:B2000|2:636506819989518425|3:YS01|4:C1001|5:18798|
  # 6:Y|7:N|8:0|9:NA|10:9898990088|
  # 11:mk.chekuri@gmail.com|12:NA|13:BXXCG7754K|
  # 14: 100000|15:NA|16:NA|17:NA|18:NA|
  # 19:0|20:NA|
  # 21:BSC:<TERMINAL_ID=1042~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>|22:Cash:<Remarks=123456>|23:006290100012468|24:OTNS00007XXA63|
  # 25: a=10|26:a b=20|27:a b c=30|28:a b c d=40|29:a b c d e=50|
  # 30:NA|31:NA|32:NA|33:NA|34:NA|35:NA|
  # 36:NA|37:NA|38:NA|39:NA|
  # 40:NA|41:NA|42:NA|43:Y|44:0
  )

  # Message Code(B2001) |Status |Error Code |Error Desc | Order No |Agent institution Id |
  # Channel Id | BBPS Transaction Ref Id | Agent Id |Customer name |Customer mobile |
  # Customer email |Customer Aadhar No |Customer PAN id | Channel |Payment Mode|
  # Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |
  # Additional Field 5| Additional Field 6| Additional Field 7| Additional Field 8|
  # ON-US/OFF-US FLAG | CCF2 Charges
  #
  # Example:
  # B2001|Y|000|Successful|ASD1503901571142|YS01|C1001|YS0117344605|
  # YS01AB2100000112 3458|Manoj|9898990091|mk.chekuri@gmail.com|NA|
  # BXXCG7754K|BSC|Cash|ASD1503901 571142PAYREF173446050917E|
  # ASD1503901571142PAYMSG1734460509172|2016-07-01|2016- 09-30|
  # 12303091|Sept|NA|NA|Y|0
  # B2001|Y|000|Successful|R20062020051032182|YB28|C1001|YB01f6fef28a|YB01YB28MOB519101711|NA|8451888620|NA|NA|NA|MOB|NEFT|R20062020051032182FETCHREF200511200|R20062020051032182PAYMSG20131120062|2020-05-26|2020-06-15|504974258|N8A|NA|NA|928ee2d5|NA
  response_fields(
    [
        :message_code, :status, :error_code, :error_desc, :order_number, :agent_institution_id, :channel_id,
        :bbps_ref_id, :agent_id, :customer_name, :customer_mobile, :customer_email, :customer_aadhar_no, :customer_pan_id,
        :channel, :payment_mode, :additional_field_1, :additional_field_2, :additional_field_3, :additional_field_4, :additional_field_5,
        :additional_field_6, :additional_field_7, :additional_field_8, :on_us_off_us_flag, :ccf2_charges
    ]
  )

  def message_code
    'B2000'
  end

  def customer_name
    params[:customer_name]
  end

  def order_number
    # needs to be generated from the adapter and sent here
    params[:order_number]
  end

  def on_us_off_us
    'Y'
  end

  def ccf_charges
    0
  end

  def split_pay
    "N"
  end

  def split_pay_amount
    0
  end

  def quick_pay
    params[:quick_pay] || "N"
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

  def bill_date
    params[:bill_date]
  end

  def due_date
    params[:due_date]
  end

  def bill_number
    params[:bill_number]
  end

  def bill_period
    params[:bill_period]
  end

  # this is because the payments need to be sent in paisa
  def amount
    (params[:amount]&.to_f * 100).round(0)
  end

  def payment_mode
    # currently hard coded, but will become dynamically done based on the
    # beneficiary's details in the future
    "NEFT:<IFSC=SBIN0001114~AccountNo=34968635304>"
  end

  def initiating_channel
    # "BSC:<TERMINAL_ID=1042~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>"
    # "BSC:<TERMINAL_ID=1042~MOBILE=9723468155~GEOCODE=28.6139,78.5555~POSTAL_CODE=400004>"
    # "MOB:<IP=13.126.31.9~IMEI=1234~OS=Android~APP=Finly>"
    "MOB:<IP=13.232.176.84~IMEI=1234~OS=Android~APP=Finly>"
  end

  def debit_account_number
    # todo - have to fetch this from a YAML in the future
    "002281300008292"
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
            message_code: result['response.parsed']['message_code'],
            status: result['response.parsed']['status'],
            error_code: result['response.parsed']['error_code'],
            error_desc: result['response.parsed']['error_desc'],
            order_number: result['response.parsed']['order_number'],
            agent_institution_id: result['response.parsed']['agent_institution_id'],
            channel_id: result['response.parsed']['channel_id'],
            bbps_ref_id: result['response.parsed']['bbps_ref_id'],
            agent_id: result['response.parsed']['agent_id'],
            customer_name: result['response.parsed']['customer_name'],
            customer_mobile: result['response.parsed']['customer_mobile'],
            customer_email: result['response.parsed']['customer_email'],
            customer_aadhar_no: result['response.parsed']['customer_aadhar_no'],
            customer_pan_id: result['response.parsed']['customer_pan_id'],
            channel: result['response.parsed']['channel'],
            payment_mode: result['response.parsed']['payment_mode'],
            additional_field_1: result['response.parsed']['additional_field_1'],
            additional_field_2: result['response.parsed']['additional_field_2'],
            additional_field_3: result['response.parsed']['additional_field_3'],
            additional_field_4: result['response.parsed']['additional_field_4'],
            additional_field_5: result['response.parsed']['additional_field_5'],
            additional_field_6: result['response.parsed']['additional_field_6'],
            additional_field_7: result['response.parsed']['additional_field_7'],
            additional_field_8: result['response.parsed']['additional_field_8'],
            on_us_off_us_flag: result['response.parsed']['on_us_off_us_flag'],
            ccf2_charges: result['response.parsed']['ccf2_charges']
        }
    )
  end

  def self.handle_error(data)
    data
  end

end