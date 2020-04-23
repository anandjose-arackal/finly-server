require 'resolv'
class UserSessions::Create < BaseOperation
  attr_accessor :user, :status, :session, :token

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
    self.token = params[:response]&.token || RequestStoreUtil.current_token
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
      if self.token.blank?
        add_message :error, 'Token not found'
        return
      end
    end

    # if self.params[:username].blank?
    #   add_message :error, 'Username not found'
    #   return
    # end
  end

  def process
    args = {}
    args[:status_id] = UserSessionStatus.id_for(self.status)
    args[:message] = params[:message]
    enrich_user args
    enrich_request args
    enrich_access args
    enrich_geo_location args
    enrich_device args
    enrich_ip args
    enrich_user_agent args
    associate_admin_user args
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
    RequestStoreUtil.set_current_company self.user&.company
    RequestStoreUtil.set_current_session self.session
    RequestStoreUtil.set_current_event self.session.events.last
    RequestStoreUtil.set_current_device self.session.user_device

    self.token&.update(status_id: self.session.status_id, message: self.session.message)
  end

  def success
    UserSessions::Create::Success.new(user, {session: self.session}, messages)
  end

  protected

  def enrich_user(args)
    args[:company_id] = user&.company_id
    args[:user_id] = user&.id
    args[:access_token] = self.token
    args[:scopes] = self.token&.scopes&.to_s || params[:scope]
    args[:scopes] = args[:scopes].join(' ') if args[:scopes].respond_to?(:each)
    args[:username] = params[:username]
  end

  def enrich_access(args)
    args[:started_at] = DateTime.now
    args[:last_request_at] = DateTime.now
  end

  def enrich_request(args)
    args[:referrer] = RequestStoreUtil.current_request.referer
    args[:ip] = RequestStoreUtil.current_request.remote_ip
    args[:user_agent] = RequestStoreUtil.current_request.user_agent
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
    geo_ip = Geocoder.search(RequestStoreUtil.current_request.remote_ip)
    # geo_ip = Geocoder.search('106.51.71.232')
    geo_ip = geo_ip.first if geo_ip.respond_to?(:each)
    data = geo_ip&.data
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
    # # todo Temporary as frontend dev is not available
    # args[:client_type] = params[:client_type]
    # # todo Temporary as frontend dev is not available
    # # return if true
    #
    # return if user.nil?
    # return

    device = params[:user_device]
    if device.blank?
      result = UserDevices::FindOrCreate.(user, params)
      unless result.success?
        # todo Temporary. Remove once user device is supported for mobile apps and API
        # args[:status_id] = UserSessionStatus.id_for(:failed)
        # args[:message] = result.messages[:error].to_sentence
        # todo Temporary. Remove once user device is supported for mobile apps and API
        return
      end
      device = result.device
    end

    args[:user_device_id] = device.id
    # args[:client_type] = result.device.client_type
    unless device.valid? and UserDeviceStatus.ids_for(:unverified, :verified).include?(device.status_id)
      args[:status_id] = UserSessionStatus.id_for(:failed)
      args[:message] = device.message
      return
    end
  end

  def enrich_ip(args)
    return if user.nil?

    user_ip = params[:user_ip]
    if user_ip.blank?
      result = UserIps::FindOrCreate.(user, params)
      unless result.success?
        args[:status_id] = UserSessionStatus.id_for(:failed)
        args[:message] = result.messages[:error].to_sentence
        # add_message :error, result.messages[:error].to_sentence
        return
      end
      user_ip = result.ip
    end

    args[:user_ip_id] = user_ip.id
    unless user_ip.valid?
      args[:status_id] = UserSessionStatus.id_for(:failed)
      args[:message] = user_ip.message
      return
    end
  end

  def enrich_user_agent(args)
    return if user.nil?

    user_agent_client = params[:user_agent_client]
    if user_agent_client.blank?
      result = UserAgentClients::FindOrCreate.(user, params)
      unless result.success?
        args[:status_id] = UserSessionStatus.id_for(:failed)
        args[:message] = result.messages[:error].to_sentence
        # add_message :error, result.messages[:error].to_sentence
        return
      end
      user_agent_client = result.user_agent_client
    end

    args[:user_agent_client_id] = user_agent_client.id
    unless user_agent_client.valid?
      args[:status_id] = UserSessionStatus.id_for(:failed)
      args[:message] = user_agent_client.message
      return
    end
  end

  def associate_admin_user(args)
    return unless user.present?
    return unless params[:admin_user_id].present?

    args[:admin_user_id] = params[:admin_user_id]
    args[:admin_access_reason] = params[:admin_access_reason]
    args[:admin_access_reason_details] = params[:admin_access_reason_details]
    args[:admin_access_requested_by] = params[:admin_access_requested_by]
  end

  def set_event(args)
    args[:events_attributes] = [{}]
    args[:events_attributes][0][:ip] = RequestStoreUtil.current_request.remote_ip
    args[:events_attributes][0][:http_method] = RequestStoreUtil.current_request.method_symbol
    args[:events_attributes][0][:app] = RequestStoreUtil.current_app
    args[:events_attributes][0][:path] = RequestStoreUtil.current_request.path
    args[:events_attributes][0][:controller] = params[:controller]
    args[:events_attributes][0][:action] = params[:action]
    args[:events_attributes][0][:view] = current_view
    args[:events_attributes][0][:status_id] = UserSessionStatus.id_for(self.status)
    args[:events_attributes][0][:message] = params[:message]
  end

end
