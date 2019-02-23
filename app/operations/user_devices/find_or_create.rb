class UserDevices::FindOrCreate < BaseOperation

  class UserDevices::FindOrCreate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :device

    def init
      self.device = params[:device]
    end

  end

  attr_accessor :device, :device_property

  def self.call(params)
    self.new(params).run
  end

  def initialize(params)
    super(nil, params)
  end

  def process
    self.device = device_property_from_request
  end

  def success
    UserDevices::FindOrCreate::SuccessPresenter.new(user, {device: self.device}, messages)
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
    UserDevice::DEVICES.each do |type, device|
      if params[:scope].include?(device[:authentication_scope].to_s)
        fingerprint_key = device[:klass].obfuscation_map[:fingerprint]
        fingerprint = request_properties&.dig(device[:device_key].to_s, fingerprint_key)
        user_device = nil
        # Find
        if fingerprint.present?
          user_device = UserDevice.not_incomplete.find_by_fingerprint(fingerprint)
        end

        # Create
        if user_device.nil?
          user_device = UserDevice.new(fingerprint: fingerprint)
          user_device.send "#{device[:create_attributes_key]}=", device_property_for(device[:klass], request_properties[device[:device_key].to_s])
          user_device.type_id = device[:user_device_type]

          if user_device.incomplete?
            user_device.status_id = UserDeviceStatus.id_for(:incomplete)
          else
            user_device.status_id = UserDeviceStatus.id_for(:unverified)
          end

          user_device.save
        end

        return user_device
      end
    end
    nil
  end

  def device_property_for(device_klass, x_finly_rp)
    attributes = {}
    device_klass.obfuscation_map.each {|attribute, id| attributes[attribute] = x_finly_rp[id]}
    device_klass.new(attributes)
  end

end