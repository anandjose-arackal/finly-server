class Bbps::BillValidation < Bbps::Api

  schema do
    params do
      required(:biller_id).filled
      required(:mobile_number).filled
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

  path "fetch"

  # Message Code (B1100) | Order No | Agent institution Id | Channel Id | Agent Id | Customer mobile | Biller Id |
  # Customer Param 1 | Customer Param 2 | Customer Param 3 | Customer Param 4 | Customer Param 5 |
  # AdditionalTag1Name | AdditionalTag2Name | AdditionalTag3Name | AdditionalTag4Name | AdditionalTag5Name |
  # Additional Field 1 | Additional Field 2 | Additional Field 3 | Additional Field 4 | Additional Field 5 |
  # Additional Field 6 | Additional Field 7 | Additional Field 8 | Additional Field 9 | Additional Field 10
  #
  # Example:
  # B1100|VALIDORDERNU0IU45L45678R|YS01|C1001|18798|9898990083|OTNS00005XXZ43|a=10|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  request_fields(
      [
          :message_code, :order_number, :agent_institution_id, :channel_id, :agent_id,
          :customer_mobile, :biller_id,
          :customer_param_1, :customer_param_2, :customer_param_3, :customer_param_4, :customer_param_5,
          :additional_tag_1_name, :additional_tag_2_name, :additional_tag_3_name, :additional_tag_4_name,
          :additional_tag_5_name,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )

  # Message Code (B1101) | Status | Error Code | Error Desc | Order No | Agent institution Id | Channel Id | Customer mobile |
  # AdditionalTag1Name | AdditionalTag2Name | AdditionalTag3Name | AdditionalTag4Name | AdditionalTag5Name |
  # Additional Field 1 | Additional Field 2 | Additional Field 3 | Additional Field 4 | Additional Field 5 |
  # Additional Field 6 | Additional Field 7 | Additional Field 8 | Additional Field 9 | Additional Field 10
  #
  # Example: B1101|Y|000|Success|4567CD34000001123456OU01AI340|YS02|YS01YS01|9999999999|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :order_number, :agent_institution_id, :channel_id,
          :customer_mobile,
          :additional_tag_1_name, :additional_tag_2_name, :additional_tag_3_name, :additional_tag_4_name,
          :additional_tag_5_name,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )

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

  def message_code
    'B1100'
  end

  def biller_id
    params[:biller_id]
  end

  def customer_mobile
    params[:mobile_number]
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

  def additional_tag_1_name
    amount_for(:amount_1)
  end

  def additional_tag_2_name
    amount_for(:amount_2)
  end

  def additional_tag_3_name
    amount_for(:amount_3)
  end

  def additional_tag_4_name
    amount_for(:amount_4)
  end

  def additional_tag_5_name
    amount_for(:amount_5)
  end

  def self.handle_success(result)
    OpenStruct.new(
        {
            # Add Order ID
            order_number: result['response.parsed']['order_number'],
            status: result['response.parsed']['status'],
            error_code: result['response.parsed']['error_code'],
            error_description: result['response.parsed']['error_desc']
        }
    )
  end

  def parse_response(user, params, response)
    parsed_response = {}
    received_response = JSON.parse(response.body)
    return Failure("Invalid response") unless response.status == 200
    return Failure("Invalid response") unless received_response&.dig("response").present?
    return Failure("Error connecting with BBPS") if received_response&.dig("response")["status"]!= "SUCCESS"
    parsed_response["status"] = received_response&.dig("response")["status"]
    parsed_response["bbps_ref_id"] = received_response["response"]["response"]["refId"]
    parsed_response["error_code"] = received_response["response"]["response"]["billDetails"]["complianceRespCd"]
    parsed_response["error_desc"] = received_response["response"]["response"]["billDetails"]["complianceReason"]
    parsed_response
  end

end