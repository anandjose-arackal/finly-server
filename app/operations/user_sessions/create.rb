require 'resolv'
class UserSessions::Create < BaseOperation
  attr_accessor :oauth_response, :user, :status, :session

  class UserSessions::Create::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :session, :event

    def init
      self.session = params[:session]
      self.event = self.session.events.last
    end

  end

  def self.call(status, params)
    self.new(status, params).run
  end

  def initialize(status, params)
    super(params[:user], params)
    self.status = status
    self.oauth_response = params[:response]
  end

  def pre_validate
    params_present?
    return if has_errors?

    if self.status.blank?
      add_message :error, 'Status not found'
      return
    end

    if self.status == :authorized
      if params[:user].blank?
        add_message :error, 'User not found'
        return
      end
      if self.oauth_response.blank?
        add_message :error, 'Token not found'
        return
      end
    end

    if self.params[:username].blank?
      add_message :error, 'Username not found'
      return
    end
  end

  def process
    args = {}
    args[:status_id] = UserSessionStatus.id_for(self.status)
    enrich_user args
    enrich_request args
    enrich_access args
    enrich_geo_location args
    enrich_device args
    # enrich_platform args
    set_event args
    return if has_errors?
    self.session = UserSession.new args
    unless self.session.valid?
      add_message :error, session.errors.full_messages
      return
    end
    self.session.save
  end

  def post_process
    RequestStoreUtil.set_current_user self.user
    RequestStoreUtil.set_current_session self.session
    RequestStoreUtil.set_current_event self.session.events.last
    RequestStoreUtil.set_current_device self.session.user_device
  end

  def success
    UserSessions::Create::Success.new(user, {session: self.session}, messages)
  end

  protected

  def enrich_user(args)
    args[:company_id] = user&.company_id
    args[:user_id] = user&.id
    args[:access_token] = self.oauth_response&.token
    args[:username] = params[:username]
  end

  def enrich_access(args)
    args[:started_at] = DateTime.now
    args[:last_request_at] = DateTime.now
  end

  def enrich_request(args)
    args[:referrer] = RequestStoreUtil.current_request.referer
    args[:ip] = RequestStoreUtil.current_request.remote_ip
    ip_type = nil
    if RequestStoreUtil.current_request.remote_ip =~ Resolv::IPv4::Regex
      ip_type = 'ipv4'
    elsif RequestStoreUtil.current_request.remote_ip =~ Resolv::IPv6::Regex
      ip_type = 'ipv6'
    end
    args[:ip_type] = ip_type
    args[:landing_page] = RequestStoreUtil.current_request.original_url
  end

  def enrich_geo_location(args)
    # geo_ip = Geocoder.search(RequestStoreUtil.current_request.remote_ip)
    geo_ip = Geocoder.search('106.51.71.232')
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

  def enrich_device(args)
    result = UserDevices::FindOrCreate.(user, params)
    unless result.success?
      args[:status_id] = UserSessionStatus.id_for(:failed)
      args[:message] = result.messages[:error].to_sentence
      return
    end

    args[:user_device_id] = result.device.id
    args[:device_type_id] = result.device.type_id
    unless result.device.valid?
      args[:status_id] = UserSessionStatus.id_for(:failed)
      args[:message] = result.messages[:error].to_sentence
    end
  end

  def set_event(args)
    args[:events_attributes] = [{}]
    args[:events_attributes][0][:http_method] = RequestStoreUtil.current_request.method_symbol
    args[:events_attributes][0][:app] = RequestStoreUtil.current_app
    args[:events_attributes][0][:path] = RequestStoreUtil.current_request.path
    args[:events_attributes][0][:controller] = params[:controller]
    args[:events_attributes][0][:action] = params[:action]
    args[:events_attributes][0][:view] = current_view
    args[:events_attributes][0][:status_id] = UserSessionStatus.id_for(self.status)
  end

end
