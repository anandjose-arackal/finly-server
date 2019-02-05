module RequestProperty
  attr_accessor :device_detector, :header_property

  # Device -> App, Web, API
  # DeviceType -> Desktop, Mobile in case the device is web
  # Platform -> Chrome, OkHTTP, Firefox, iOS HTTP Client
  # App version -> App version
  # OS Name ->iOS, Android, Mac, Windows, Linux
  # OS Version -> OS Version
  # device Screen Height
  # Screen Width

  # Header: "X-Finly-BTAI"

  # TODO: Handle mobile device platform, device name etc

  def initialize
    self.request = RequestStoreUtil.current_request
    self.device_detector = DeviceDetector.new(self.request.user_agent)
    self.header_property = DeviceProperty::HeaderProperty.new
  end

  def user_agent
    self.device_detector.user_agent
  end

  def self.device
    RequestStoreUtil.current_device
  end

  def self.device_type
    self.device_detector.device_type
  end

  def self.platform
    self.device_detector.name
  end

  def self.platform_version
    self.device_detector.full_version
  end

  def self.app_version
    # todo from header
  end

  def self.os_name
    self.device_detector.os_name
  end

  def self.os_version
    self.device_detector.os_full_version
  end

  def self.screen_height
    # todo from header
  end

  def self.screen_width
    # todo from header
  end

  def self.mouse_pos_x
    # todo from header
  end

  def self.mouse_pos_y
    # todo from header
  end

  def self.fingerprint
    # todo from header
  end

  class RequestProperty::HeaderProperty
    attr_accessor :fingerprint, :path, :timestamp

    def initialize

    end

  end

  class RequestProperty::FingerPrint
    attr_accessor :fingerprint

    def initialize

    end

    def valid?

    end

    def matches_header?

    end

  end

end
