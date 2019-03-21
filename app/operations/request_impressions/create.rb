class RequestImpressions::Create < BaseOperation
  attr_accessor :request_impression, :current_request

  class RequestImpressions::Create::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :request_impression

    def init
      self.request_impression = params[:request_impression]
    end

  end

  def self.call(request, params)
    self.new(request, params).run
  end
  
  def initialize(request, params)
    self.current_request = request
    self.params = params
  end

  def pre_validate
    params_present?
  end

  def process
    args = {}
    enrich_username args
    enrich_request args
    enrich_geo_location args
    set_event args
    return if has_errors?
    self.request_impression = RequestImpression.new args
    unless self.request_impression.valid?
      add_message :error, request_impression.errors.full_messages
      return
    end
    self.request_impression.save
  end

  def post_process
    RequestStoreUtil.set_request_impression self.request_impression
  end

  def success
    RequestImpressions::Create::Success.new(user, {request_impression: self.request_impression}, messages)
  end

  protected

  def enrich_username(args)
    args[:username] = params[:username]
  end

  def enrich_request(args)
    args[:referrer] = self.current_request.referer
    args[:ip] = self.current_request.remote_ip
    args[:user_agent] = self.current_request.user_agent
    ip_type = nil
    if self.current_request.remote_ip =~ Resolv::IPv4::Regex
      ip_type = 'ipv4'
    elsif self.current_request.remote_ip =~ Resolv::IPv6::Regex
      ip_type = 'ipv6'
    end
    args[:ip_type] = ip_type
    args[:landing_page] = self.current_request.original_url
  end

  def enrich_geo_location(args)
    geo_ip = Geocoder.search(self.current_request.remote_ip)
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
    args[:http_method] = self.current_request.method_symbol
    args[:path] = self.current_request.path
    args[:controller] = params[:controller]
    args[:action] = params[:action]
  end

end