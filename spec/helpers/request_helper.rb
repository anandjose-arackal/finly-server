module RequestHelper

  DEFAULT_DATA = {
      timestamp_s: DateTime.now.strftime('%Q'),
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.96 Safari/537.36',
      timezone: 'India Standard Time',
      language: 'en-IN',
      system_language: nil,
      browser: 'Chrome',
      browser_version: '72.0.3626.96',
      browser_engine: 'WebKit',
      browser_engine_version: '537.36',
      os_name: 'Mac OS',
      os_version: '10.14.1',
      screen_width: '1920',
      screen_height: '1080',
      device_x_dpi: nil,
      device_y_dpi: nil,
      color_depth: '24',
      java_enabled: false,
      java_version: nil,
      flash_enabled: false,
      flash_version: nil,
      silver_light_enabled: false,
      silver_light_version: nil,
      is_mime_types: true,
      mime_types_list: ', Portable Document Format, Native Client Executable, Portable Native Client Executable',
      fonts_list: 'Adobe Fangsong Std, Adobe Hebrew, Adobe Ming Std, Arial Black, Arial, Bauhaus 93, Calibri, Chalkduster, Comic Sans MS, Courier New, Georgia, Hiragino Sans GB, Impact, Kozuka Gothic Pr6N, Menlo, Microsoft Sans Serif, Papyrus, Plantagenet Cherokee, Rockwell, Symbol, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings, Wingdings',
      is_local_storage: true,
      is_session_storage: true,
      is_cookie: true,
      plugins: 'Chrome PDF Plugin, Chrome PDF Viewer, Native Client',
      is_mobile: true,
  }

  def random_ip
    IPAddr.new(rand(2 ** 32), Socket::AF_INET).to_s
  end

  def random_fingerprint
    rand(10 ** 10).to_s.rjust(10, '0')
  end

  def authentication_headers_for(type, properties = {})
    headers = {}
    case type
    when :web
      headers['X-Finly-RP'] = Base64.encode64(x_finly_rp_web(properties).to_json)
    end
    headers
  end

  def x_finly_rp_web(params)
    args = {}
    id = params[:id] || '13'
    args[id] = {}
    args[id]['11'] = params.has_key?(:timestamp_s) ? params[:timestamp_s] : DEFAULT_DATA[:timestamp_s]
    args[id]['16'] = params.has_key?(:user_agent) ? params[:user_agent] : DEFAULT_DATA[:user_agent]
    args[id]['19'] = params.has_key?(:timezone) ? params[:timezone] : DEFAULT_DATA[:timezone]
    args[id]['7'] = params.has_key?(:fingerprint) ? params[:fingerprint] : random_fingerprint
    args[id]['5'] = params.has_key?(:language) ? params[:language] : DEFAULT_DATA[:language]
    args[id]['20'] = params.has_key?(:system_language) ? params[:system_language] : DEFAULT_DATA[:system_language]
    args[id]['27'] = params.has_key?(:browser) ? params[:browser] : DEFAULT_DATA[:browser]
    args[id]['21'] = params.has_key?(:browser_version) ? params[:browser_version] : DEFAULT_DATA[:browser_version]
    args[id]['8'] = params.has_key?(:browser_engine) ? params[:browser_engine] : DEFAULT_DATA[:browser_engine]
    args[id]['23'] = params.has_key?(:browser_engine_version) ? params[:browser_engine_version] : DEFAULT_DATA[:browser_engine_version]
    args[id]['18'] = params.has_key?(:os_name) ? params[:os_name] : DEFAULT_DATA[:os_name]
    args[id]['25'] = params.has_key?(:os_version) ? params[:os_version] : DEFAULT_DATA[:os_version]
    args[id]['10'] = params.has_key?(:screen_width) ? params[:screen_width] : DEFAULT_DATA[:screen_width]
    args[id]['24'] = params.has_key?(:screen_height) ? params[:screen_height] : DEFAULT_DATA[:screen_height]
    args[id]['2'] = params.has_key?(:device_x_dpi) ? params[:device_x_dpi] : DEFAULT_DATA[:device_x_dpi]
    args[id]['26'] = params.has_key?(:device_y_dpi) ? params[:device_y_dpi] : DEFAULT_DATA[:device_y_dpi]
    args[id]['13'] = params.has_key?(:color_depth) ? params[:color_depth] : DEFAULT_DATA[:color_depth]
    args[id]['15'] = params.has_key?(:java_enabled) ? params[:java_enabled] : DEFAULT_DATA[:java_enabled]
    args[id]['17'] = params.has_key?(:java_version) ? params[:java_version] : DEFAULT_DATA[:java_version]
    args[id]['30'] = params.has_key?(:flash_enabled) ? params[:flash_enabled] : DEFAULT_DATA[:flash_enabled]
    args[id]['12'] = params.has_key?(:flash_version) ? params[:flash_version] : DEFAULT_DATA[:flash_version]
    args[id]['29'] = params.has_key?(:silver_light_enabled) ? params[:silver_light_enabled] : DEFAULT_DATA[:silver_light_enabled]
    args[id]['6'] = params.has_key?(:silver_light_version) ? params[:silver_light_version] : DEFAULT_DATA[:silver_light_version]
    args[id]['9'] = params.has_key?(:is_mime_types) ? params[:is_mime_types] : DEFAULT_DATA[:is_mime_types]
    args[id]['4'] = params.has_key?(:mime_types_list) ? params[:mime_types_list] : DEFAULT_DATA[:mime_types_list]
    args[id]['1'] = params.has_key?(:fonts_list) ? params[:fonts_list] : DEFAULT_DATA[:fonts_list]
    args[id]['3'] = params.has_key?(:is_local_storage) ? params[:is_local_storage] : DEFAULT_DATA[:is_local_storage]
    args[id]['14'] = params.has_key?(:is_session_storage) ? params[:is_session_storage] : DEFAULT_DATA[:is_session_storage]
    args[id]['22'] = params.has_key?(:is_cookie) ? params[:is_cookie] : DEFAULT_DATA[:is_cookie]
    args[id]['28'] = params.has_key?(:plugins) ? params[:plugins] : DEFAULT_DATA[:plugins]
    args[id]['31'] = params.has_key?(:is_mobile) ? params[:is_mobile] : DEFAULT_DATA[:is_mobile]
    args
  end

end