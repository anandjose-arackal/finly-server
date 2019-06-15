class UserDevices::FindOrCreate < BaseOperation

  class UserDevices::FindOrCreate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :device

    def init
      self.device = params[:device]
    end

  end

  attr_accessor :device, :client

  def pre_validate
    user_present?
  end

  def init
    self.device = client_from_request
  end

  def validate
    if self.device.blank?
      add_message :error, 'Unable to create device'
      return
    end
  end

  def success
    UserDevices::FindOrCreate::SuccessPresenter.new(user, {device: self.device}, messages)
  end

  protected

  def client_from_request
    # request = RequestStoreUtil.current_request
    # headers = request.headers
    # request_properties = headers['X-Finly-RP']
    # if request_properties.nil?
    #   add_message :error, 'X-Finly-RP not found'
    #   return
    # end
    # if request_properties.present?
    #   request_properties = Base64.decode64(request_properties)
    #   request_properties = JSON.parse(request_properties) if request_properties.is_a?(String)
    # else
    #   # todo fallback to user-agent instead of not creating the properties
    #   request_properties = {}
    # end
    # request_properties = request_properties.with_indifferent_access if request_properties.is_a?(Hash)
    UserDevice::DEVICES.each do |device|
      if params[:scope].include?(device.authentication_scope.to_s)
        client = client_for(device)
        return if has_errors?

        user_device = user_device_for(client)
        return user_device
      end
    end
    nil
  end

  def user_device_for(client)
    user_device = user.user_devices.valid.find_by(client: client)
    return user_device if user_device.present?
    # If not found
    user_device = UserDevice.new user:user, company: user.company, client: client, status_id: UserDeviceStatus.id_for(:unverified)
    unless client.complete?
      user_device.status_id = client.status_id
      user_device.message = client.message
    end
    user_device.save
    user_device
  end

  def client_for(config_class)
    attributes = UserDevices::XFinlyRPProcessor.from_request(params)
    if attributes.nil?
      add_message :error, 'X-Finly-RP not sent'
      return
    end

    client = config_class.completed.with_attributes(attributes)&.first
    client = config_class.create(attributes) unless client.present?
    client

    # unless client
    #   # Verify client matches with the request properties
    #   differences = client.differences(attributes)
    #   # If there is a mismatch, flag it as attribute mismatch
    #   if differences.present?
    #     # Mark client status as config mismatch
    #     attributes[:status_id] = UserDeviceStatus.id_for(:attribute_mismatch)
    #     attributes[:message] = "Attribute mismatch for #{differences.to_sentence}"
    #     client = config_class.create(attributes)
    #   end
    # else
    #   client = config_class.create(attributes)
    # end
  end

  # def client_attributes_for(config_class, x_finly_rp)
  #   attributes = {}
  #   config_class.obfuscation_map.each {|attribute, id| attributes[attribute] = x_finly_rp[id]}
  #   attributes
  # end

end