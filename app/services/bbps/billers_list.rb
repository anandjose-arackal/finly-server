class Bbps::BillersList < Bbps::Api

  schema do
    params do
      # required(:category).filled
    end
  end

  http_method :get
  path "biller/readbillermdmdata"
  url 'https://yesbbps.transxt.in:9443/portal/service/' 
  header "AUTH", ENV['BILLERS_LIST_AUTH']


  def self.build_matcher(options, result)
    Dry::Matcher.new(
        success: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Success", result; result['response.parsed'].present?},
            resolve: -> (result) { handle_success(result) }
        ),
        error: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Error", result; !result['response.parsed'].present?},
            resolve: -> (result) { handle_error(result['response.parsed']) }
        ),
        failure: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Failure", result; true},
            resolve: -> (result) {result}
        )
    )
  end

  #parse -> (user, params, response) { parse_json_response(:billers_list, user, params, response) }

  # Message Code(B7000)|RefNo | Agent Institution Id| Channel Id| Category |Last Updated Timestamp|AdditionalField1|Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  # Example: B7000|M3TEST8976543|YS01|C1001|Mobile|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA
  request_fields()

  # Message Code(B7001) |Status |Error Code |Error Desc | Ref No | Agent Institution Id |Channel Id| [List of BillerId, Biller Name and Category in JSON format]|Additional Field 1 |Additional Field 2 |Additional Field 3 |Additional Field 4 |Additional Field 5 |Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10| Additional Field 11| Additional Field 12| Additional Field 13| Additional Field 14|Additional Field 15
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id,
          :channel_id, :billers_list,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  def message_code
    'B7000'
  end

  def category
    params[:category]
  end

  def body
  end

  def parse_response(user, params, response)
    parsed_response = {}
    return Failure("Invalid response") unless response.status == 200

    # parsed_response["error_code"] = received_response["response"]["complianceRespCd"]
    # parsed_response["error_desc"] = received_response["response"]["complianceReason"]
    # parsed_response["status"] = received_response&.dig("status")
    # return Failure("Error connecting with BBPS") if received_response&.dig("status")!= "SUCCESS"
    
    parsed_response['billers_list'] = JSON.parse(response.body)['biller']
  end

  def self.handle_success(result)
    list = result['response.parsed']
    list.map { |item| format(item) }
  end

  def self.handle_error(data)
    data
  end

end