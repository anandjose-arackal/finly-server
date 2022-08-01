class Vendors::Support::GstrFiling < Vendors::Support::Base

  attr_accessor :gst_api_call_log, :gst_filing_records, :gstin, :for_date,
                :gstin_location_id, :invoice_id, :vendor_id

  class Vendors::Support::GstrFiling::DefaultPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :gst_filing_records_response

    def init
      Rails.logger.debug params[:gst_filing_records_response].to_json

      self.gst_filing_records_response = params[:gst_filing_records_response]
    end
  end

  def init
    super
    @gstin = params[:gstin]
    @for_date = Date.parse(params[:for_date], "%Y-%m-%d")
    # @financial_year = params[:financial_year]
    @gstin_location_id = params[:gstin_location_id]
    @invoice_id = params[:invoice_id]
    @vendor_id = params[:vendor_id]

    @config_data = ApiToken.with_name('gstin_masters_india').first rescue nil
    Rails.logger.debug @config_data
    @gst_api_call_log = nil
  end

  # private

  def validate_pattern(item, pattern)
    unless item =~ pattern
      return false
    end
    true
  end

  def pre_validate

  end

  def validate
    success = true
    if @gstin.blank? || !validate_pattern(@gstin, Constants::VALID_GSTIN)
      success = false
      add_message :error, "Please provide a valid GSTIN"
    end
    success
  end

  def parse_return_period_to_date(ret_prd)
    re = /(\d{2})(\d{4})/m

    tokens = ret_prd.scan(re)[0]
    if tokens.size < 0
      raise Exception.new "Problem parsing ret_prd in API"
    end
    month = tokens[0]
    year = tokens[1]

    return Date.strptime("#{year}-#{month}-01", "%Y-%m-%d")
  end


  def authenticate
    if @config_data.blank?
      return false
    end

    auth_data = {
      username: @config_data.username,
      password: @config_data.password,
      client_id: @config_data.client_id,
      client_secret: @config_data.client_secret,
      grant_type: @config_data.grant_type
    }

    url = @config_data.base_url + "/oauth/access_token"

    auth_connection = Faraday.new(url: url) do |req|
      req.adapter Faraday.default_adapter

      req.headers['Content-Type'] = @config_data.content_type
    end

    Rails.logger.info "Making GSTIN Authentication API Call"
    auth_response = auth_connection.post {|req| req.body = auth_data.to_json }

    unless auth_response.status.present? && auth_response.status == 200
      return false
    end

    auth_response_body = ActiveSupport::HashWithIndifferentAccess.new JSON.parse(auth_response.body)
    if auth_response_body.keys.include?("error")
      return false
    end

    auth_response_body[:access_token]
  end

  def call_gstfiling_api(financial_year)
    auth_token = authenticate
    config_data = @config_data

    api_url = config_data.base_url + "/commonapis/trackReturns?gstin=#{@gstin}&fy=#{financial_year}"

    @gst_api_call_log = GstFilingApiCallLog.new do |obj|
      obj.gstin = @gstin
      obj.financial_year = financial_year
      obj.request_url = api_url
      obj.vendor_id = @vendor_id
      obj.invoice_id = @invoice_id
    end

    connection = Faraday.new(url: api_url) do |req|
      req.adapter Faraday.default_adapter # make requests with Net::HTTP

      req.headers['Content-Type'] = config_data.content_type
      req.headers['client_id'] = config_data.client_id
      req.headers['Authorization'] = "Bearer #{auth_token}"
    end

    if connection.blank?
      raise GstAPIError.new("Couldn't create connection for GST API")
    end

    api_response = connection.get

    if api_response.blank?
      raise GstAPIError.new("Couldn't get response from the GST API")
    end

    unless api_response.status && api_response.status == 200
      raise GstAPIError.new("GST API did not respond correctly")
    end

    response_body = ActiveSupport::HashWithIndifferentAccess.new JSON.parse(api_response.body)

    @gst_api_call_log.success = !response_body[:error]
    @gst_api_call_log.response_json = api_response.body

    response_body
  end

  def save_or_update_filing(filing_hash, financial_year)
    gst_filing_record = GstFilingRecord.lock.where(
      gstin: @gstin,
      return_period: filing_hash[:ret_prd],
      return_type: filing_hash[:rtntype]
    ).first

    gst_filing_record ||= GstFilingRecord.new

    gst_filing_record.gstin = @gstin
    gst_filing_record.financial_year = financial_year
    gst_filing_record.date_of_filing = filing_hash[:dof]
    gst_filing_record.mode_of_filing = filing_hash[:mof]
    gst_filing_record.return_period = filing_hash[:ret_prd]
    gst_filing_record.return_period_date = parse_return_period_to_date(filing_hash[:ret_prd])
    gst_filing_record.status = filing_hash[:status]
    gst_filing_record.valid_text = filing_hash[:valid]
    gst_filing_record.return_type = filing_hash[:rtntype]
    gst_filing_record.arn = filing_hash[:arn]

    gst_filing_record.yes_bank_vendor_id = @vendor_id
    gst_filing_record.gstin_location_id = @gstin_location_id

    gst_filing_record.save!
    gst_filing_record
  end

  def save_gstfiling_data(filing_list, financial_year)
    gst_filing_records = []
    filing_list.each do |filing_hash|
      gst_filing_records << save_or_update_filing(filing_hash.with_indifferent_access, financial_year)
    end
    gst_filing_records
  end

  def get_required_financial_years
    this_year = @for_date.year
    prev_year = this_year - 1

    month = @for_date.month

    fin_year_starting_with_curr_year = DateUtils.fin_year_starting_with_year this_year
    fin_year_starting_with_prev_year = DateUtils.fin_year_starting_with_year prev_year

    case month
    when 5
      return [fin_year_starting_with_curr_year, fin_year_starting_with_prev_year]
    when 6..12
      return [fin_year_starting_with_curr_year]
    when 1..4
      return [fin_year_starting_with_prev_year]
    else
      return []
    end
  end

  def handle_api_call(financial_year)
    api_resp_hash = call_gstfiling_api(financial_year)

    if api_resp_hash[:error]
      raise GstAPIError.new(api_resp_hash[:data][:error][:message])
    end

    filing_list = api_resp_hash[:data][:EFiledlist]
    save_gstfiling_data filing_list, financial_year
  end

  def process
    self.gst_filing_records = get_gst_filing_records params[:forced_refresh]
  rescue GstAPIError => err
    Rails.logger.error err
    add_message :error, err.message
    return false
  rescue Exception => err
    Rails.logger.error err
    add_message :error, "Something went wrong!"
    return false
  ensure
    Rails.logger.debug "Rescuing due to error"
    if @gst_api_call_log.present?
      @gst_api_call_log.save
    end
    true
  end

  def success
    presenter_params = {
      gst_filing_records_response: gst_filing_records
    }
    Vendors::Support::GstrFiling::DefaultPresenter.new(@current_user, presenter_params, messages)
  end

  def get_gst_filing_records_per_fin_yr(financial_year, force_refresh = false)
    if force_refresh
      handle_api_call financial_year
    end

    gst_filing_records = GstFilingRecord.where(
      financial_year: financial_year,
      gstin: @gstin
    ).order(return_period_date: :desc)

    unless gst_filing_records.present?
      gst_filing_records = handle_api_call financial_year
    end

    gst_filing_records
  end

  def get_gst_filing_records(forced_refresh = false)
    records_all = []
    get_required_financial_years().each do |financial_year|
      records_all += (get_gst_filing_records_per_fin_yr financial_year, forced_refresh)
    end
    records_all
  end
end
