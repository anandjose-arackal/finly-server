class RequestImpressions::OnRackAttackBlock < BackgroundOperation
  attr_accessor :request_impression, :current_request

  def self.call(request, params)
    self.new.perform(request, params)
  end

  def self.call_async(request, params)
    self.perform_async(request, params)
  end

  def perform(request, params)
    self.current_request = request
    self.params = params
    run
  end

  def process
    self.params = {} if self.params.nil?
    args = {}
    enrich_username args
    enrich_request args
    enrich_geo_location args
    set_event args
    set_block args
    return if has_errors?
    self.request_impression = RequestImpression.new args
    unless self.request_impression.valid?
      add_message :error, request_impression.errors.full_messages
      return
    end
    self.request_impression.save
  end

  protected

  def enrich_username(args)
    args[:username] = params[:username] || params[:email_mobile] || params[:email]
  end

  def enrich_request(args)
    args[:referrer] = self.current_request[:referrer]
    args[:ip] = self.current_request[:ip]
    args[:user_agent] = self.current_request[:user_agent]
    ip_type = nil
    if self.current_request[:ip] =~ Resolv::IPv4::Regex
      ip_type = 'ipv4'
    elsif self.current_request[:ip] =~ Resolv::IPv6::Regex
      ip_type = 'ipv6'
    end
    args[:ip_type] = ip_type
    args[:landing_page] = self.current_request[:landing_page]
  end

  def enrich_geo_location(args)
    geo_ip = Geocoder.search(self.current_request[:ip])
    # geo_ip = Geocoder.search('106.51.71.232')
    geo_ip = geo_ip.first if geo_ip.respond_to?(:each)
    data = geo_ip.data
    args[:continent_name] = data&.dig('continent', 'names', 'en')
    args[:continent_code] = data&.dig('continent', 'code')
    args[:country_name] = data&.dig('country', 'names', 'en')
    args[:country_code] = data&.dig('country', 'iso_code')
    args[:region_code] = data&.dig('subdivisions')&.first&.dig('iso_code')
    args[:region_name] = data&.dig('subdivisions')&.first&.dig('names', 'en')
    args[:city] = data&.dig('city', 'names', 'en')
    args[:zip] = data&.dig('postal', 'code')
    args[:latitude] = data&.dig('location', 'latitude')
    args[:longitude] = data&.dig('location', 'longitude')
    args[:accuracy_radius] = data&.dig('location', 'accuracy_radius')
  end

  def set_event(args)
    args[:http_method] = self.current_request[:http_method]
    args[:path] = self.current_request[:path]
    args[:controller] = params[:controller]
    args[:action] = params[:action]
  end

  def set_block(args)
    args[:blocked] = true
    args[:blocked_by] = :rack_attack
    args[:block_reason] = current_request[:block_reason]
    args[:response_code] = current_request[:response_code]
  end

end