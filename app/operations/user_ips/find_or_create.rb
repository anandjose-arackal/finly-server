class UserIps::FindOrCreate < BaseOperation

  class UserIps::FindOrCreate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :ip

    def init
      self.ip = params[:ip]
    end

  end

  attr_accessor :ip

  def pre_validate
    user_present?
  end

  def process
    self.ip = ip_from_request
  end

  def success
    UserIps::FindOrCreate::SuccessPresenter.new(user, {ip: ip}, messages)
  end

  protected

  def ip_from_request
    request = RequestStoreUtil.current_request
    ip_addr = request.remote_ip
    ip_type = nil
    if RequestStoreUtil.current_request.remote_ip =~ Resolv::IPv4::Regex
      ip_type = 'ipv4'
    elsif RequestStoreUtil.current_request.remote_ip =~ Resolv::IPv6::Regex
      ip_type = 'ipv6'
    end
    ip = user.user_ips.find_by_ip(ip_addr)
    return ip if ip.present?

    ip = user.user_ips.build ip: ip_addr, ip_type: ip_type, status_id: UserIpStatus.id_for(:unverified)
    unless ip.valid?
      add_message :error, ip.errors.full_messages
      return
    end
    enrich_ip(ip)
    ip.save
    ip
  end

  def enrich_ip(ip)
    geo_ip = Geocoder.search(RequestStoreUtil.current_request.remote_ip)
    geo_ip = geo_ip.first if geo_ip.respond_to?(:each)
    data = geo_ip&.data
    ip.continent_name = data&.dig('continent', 'names', 'en')
    ip.continent_code = data&.dig('continent', 'code')
    ip.country_name = data&.dig('country', 'names', 'en')
    ip.country_code = data&.dig('country', 'iso_code')
    ip.region_code = data&.dig('subdivisions')&.first&.dig('iso_code')
    ip.region_name = data&.dig('subdivisions')&.first&.dig('names', 'en')
    ip.city = data&.dig('city', 'names', 'en')
    ip.zip = data&.dig('postal', 'code')
    ip.latitude = data&.dig('location', 'latitude')
    ip.longitude = data&.dig('location', 'longitude')
    ip.accuracy_radius = data&.dig('location', 'accuracy_radius')
  end

end