class UserDevices::FindOrCreate < BaseOperation

  class UserDevices::FindOrCreate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :device, :device_property

    def init
      self.device = params[:device]
      self.device_property = params[:device_property]
    end

  end

  DEVICES = [
      {
          klass: UserDeviceBrowser,
          user_device_type: UserDeviceType.id_for(:web),
          device_key: 13,
          authentication_scope: :web,
          create_attributes_key: :user_device_web
      }
  ]

  attr_accessor :device, :device_property

  def process
    self.device_property = device_property_from_request
    self.device = user.user_devices.find_by_property(self.device_property)
  end

  def success
    UserDevices::FindOrCreate::SuccessPresenter.new(user, {device: self.device, device_property: self.device_property}, messages)
  end

  protected

  def device_property_from_request
    request = RequestStoreUtil.current_request
    headers = request.headers
    request_properties = headers['X-Finly-RP']
    if request_properties.present?
      request_properties = Base64.decode64(request_properties)
      request_properties = JSON.parse(request_properties) if request_properties.is_a?(String)
    else
      # todo fallback to user-agent instead of not creating the properties
      request_properties = {}
    end
    request_properties = request_properties.with_indifferent_access if request_properties.is_a?(Hash)
    DEVICES.each do |device|
      if params[:scope].include?(device[:authentication_scope].to_s)
        return device.find_or_create request_properties[device[:device_key].to_s]
      end
    end
    nil
  end

end