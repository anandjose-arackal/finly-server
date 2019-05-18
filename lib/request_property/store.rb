module RequestProperty::Store
  attr_accessor :device_detector, :header_property

  # Device -> App, Web, API
  # DeviceType -> Desktop, Mobile in case the device is web
  # Platform -> Chrome, OkHTTP, Firefox, iOS HTTP Client
  # App version -> App version
  # OS Name ->iOS, Android, Mac, Windows, Linux
  # OS Version -> OS Version
  # device Screen Height
  # Screen Width

  # TODO: Handle mobile device platform, device name etc

  def initialize
    self.request = RequestStoreUtil.current_request
    self.device_detector = DeviceDetector.new(self.request.user_agent)
    self.header_property = RequestProperty::HeaderProperty.new
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


  # Headers
  # "X-Finly-BTAI": {}
  class RequestProperty::Store::HeaderProperty
    attr_accessor :timestamp, :user_agent, :timezone, :fingerprint,
          :browser, :browser_version, :browser_engine, :browser_engine_version,
          :os_name, :os_version,
          :screen_width, :screen_height, :current_resolution_width, :current_resolution_height,
          :mouse_pos_x, :mouse_pos_y,
          :screen_print,
          :color_depth, :device_x_dpi, :device_y_dpi,
          :language, :system_language,
          :plugins,
          :java_enabled, :java_version, :flash_enabled, :flash_version, :silver_light_enabled, :silver_light_version,
          :is_mime_types, :mime_types_list,
          :fonts_list, :current_font,
          :is_local_storage, :is_session_storage, :is_cookie,
          :is_canvas

    # todo Android
    # StringBuffer buf = new StringBuffer();
    # buf.append("VERSION.RELEASE {"+Build.VERSION.RELEASE+"}"); -> OS Version
    # buf.append("\nVERSION.INCREMENTAL {"+Build.VERSION.INCREMENTAL+"}"); -> OS Version
    # buf.append("\nVERSION.SDK_INT {"+Build.VERSION.SDK_INT+"}");
    # buf.append("\nFINGERPRINT {"+Build.FINGERPRINT+"}"); -> device fingerprint
    # buf.append("\nBOARD {"+Build.BOARD+"}");
    # buf.append("\nBRAND {"+Build.BRAND+"}");
    # buf.append("\nDEVICE {"+Build.DEVICE+"}");
    # buf.append("\nMANUFACTURER {"+Build.MANUFACTURER+"}");
    # buf.append("\nMODEL {"+Build.MODEL+"}");

    # Session
    # -> Client Property
    # -> -> Browser
    #       :timestamp, :user_agent, :timezone, :fingerprint,
    #       :browser, :browser_version, :browser_engine, :browser_engine_version
    #       :os_name, :os_version,
    #       :screen_width, :screen_height, :current_resolution_width, :current_resolution_height,
    #       :mouse_pos_x, :mouse_pos_y,
    #       :screen_print,
    #       :color_depth, :device_x_dpi, :device_y_dpi,
    #       :language, :system_language,
    #       :plugins,
    #       :java_enabled, :java_version, :flash_enabled, :flash_version, :silver_light_enabled, :silver_light_version,
    #       :is_mime_types, :mime_types_list,
    #       :fonts_list, :current_font,
    #       :is_local_storage, :is_session_storage, :is_cookie,
    #       :is_canvas
    # -> -> Android
    # -> -> iOS
    # -> -> API


    def initialize

    end

  end

end
