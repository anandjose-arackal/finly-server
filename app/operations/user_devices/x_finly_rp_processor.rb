class UserDevices::XFinlyRPProcessor

  def self.from_client(client)
    return nil if client.blank?

    client_klass = client.class
    request_properties = properties_from_request
    return nil if request_properties.blank? or request_properties[client_klass.client_id.to_s].blank?

    x_finly_rp = attributes_for client_klass, request_properties[client_klass.client_id.to_s]
    RequestStoreUtil.set_x_finly_rp_attributes x_finly_rp

    return x_finly_rp
  end

  def self.from_request(params)
    request_properties = properties_from_request
    return nil if request_properties.blank?

    UserDevice::DEVICES.each do |device|
      if params[:scope].include?(device.authentication_scope.to_s)
        x_finly_rp = attributes_for device, request_properties[device.client_id.to_s]
        RequestStoreUtil.set_x_finly_rp_attributes x_finly_rp

        return x_finly_rp
      end
    end
    nil
  end

  private

  def self.properties_from_request
    request = RequestStoreUtil.current_request
    headers = request.headers
    request_properties = headers['X-Finly-RP']
    return nil if request_properties.nil?

    if request_properties.present?
      request_properties = Base64.decode64(request_properties)
      request_properties = JSON.parse(request_properties) if request_properties.is_a?(String)
    else
      # todo fallback to user-agent instead of not creating the properties
      request_properties = {}
    end
    request_properties = request_properties.with_indifferent_access if request_properties.is_a?(Hash)
    request_properties
  end

  def self.attributes_for(config_class, x_finly_rp)
    return nil if x_finly_rp.blank?

    attributes = {}
    config_class.obfuscation_map.each {|attribute, id| attributes[attribute] = x_finly_rp[id]}
    attributes
  end

end