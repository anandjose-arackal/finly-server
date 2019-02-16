module AuthenticationHelper

  def headers(properties = {})
    {'X-Finly-RP': Base64.encode64(default_properties(properties).to_json)}
  end

  def default_properties(params)
    args = {}
    id = params[:id] || '13'
    args[id] = {}
    args[id]['11'] = params.has_key?(:timestamp) ? params[:timestamp] : '1549636286'
    args[id]["16"] = params.has_key?(:user_agent) ? params[:user_agent] : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.96 Safari/537.36"
    args[id]["19"] = params.has_key?(:timezone) ? params[:timezone] : "India Standard Time"
    args[id]["7"] = params.has_key?(:fingerprint) ? params[:fingerprint] : "3202771635"
    args[id]["5"] = params.has_key?(:language) ? params[:language] : "en-IN"
    args[id]["20"] = params.has_key?(:system_language) ? params[:system_language] : nil
    args[id]["27"] = params.has_key?(:browser) ? params[:browser] : "Chrome"
    args[id]["21"] = params.has_key?(:browser_version) ? params[:browser_version] : "72.0.3626.96"
    args[id]["8"] = params.has_key?(:browser_engine) ? params[:browser_engine] : "WebKit"
    args[id]["23"] = params.has_key?(:browser_engine_version) ? params[:browser_engine_version] : "537.36"
    args[id]["18"] = params.has_key?(:os_name) ? params[:os_name] : "Mac OS"
    args[id]["25"] = params.has_key?(:os_version) ? params[:os_version] : "10.14.1"
    args[id]["10"] = params.has_key?(:screen_width) ? params[:screen_width] : "1920"
    args[id]["24"] = params.has_key?(:screen_height) ? params[:screen_height] : "1080"
    args[id]["15"] = params.has_key?(:current_resolution_width) ? params[:current_resolution_width] : "1920"
    args[id]["26"] = params.has_key?(:current_resolution_height) ? params[:current_resolution_height] : "1080"
    args[id]["2"] = params.has_key?(:device_x_dpi) ? params[:device_x_dpi] : nil
    args[id]["32"] = params.has_key?(:device_y_dpi) ? params[:device_y_dpi] : nil
    args[id]["13"] = params.has_key?(:color_depth) ? params[:color_depth] : "24"
    args[id]["33"] = params.has_key?(:mouse_pos_x) ? params[:mouse_pos_x] : "50"
    args[id]["12"] = params.has_key?(:mouse_pos_y) ? params[:mouse_pos_y] : "30"
    args[id]["34"] = params.has_key?(:java_enabled) ? params[:java_enabled] : false
    args[id]["17"] = params.has_key?(:java_version) ? params[:java_version] : nil
    args[id]["30"] = params.has_key?(:flash_enabled) ? params[:flash_enabled] : false
    args[id]["31"] = params.has_key?(:flash_version) ? params[:flash_version] : nil
    args[id]["29"] = params.has_key?(:silver_light_enabled) ? params[:silver_light_enabled] : false
    args[id]["6"] = params.has_key?(:silver_light_version) ? params[:silver_light_version] : nil
    args[id]["9"] = params.has_key?(:is_mime_types) ? params[:is_mime_types] : true
    args[id]["4"] = params.has_key?(:mime_types_list) ? params[:mime_types_list] : ", Portable Document Format, Native Client Executable, Portable Native Client Executable"
    args[id]["1"] = params.has_key?(:fonts_list) ? params[:fonts_list] : "Adobe Fangsong Std, Adobe Hebrew, Adobe Ming Std, Arial Black, Arial, Bauhaus 93, Calibri, Chalkduster, Comic Sans MS, Courier New, Georgia, Hiragino Sans GB, Impact, Kozuka Gothic Pr6N, Menlo, Microsoft Sans Serif, Papyrus, Plantagenet Cherokee, Rockwell, Symbol, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings, Wingdings"
    args[id]["3"] = params.has_key?(:is_local_storage) ? params[:is_local_storage] : true
    args[id]["14"] = params.has_key?(:is_session_storage) ? params[:is_session_storage] : true
    args[id]["22"] = params.has_key?(:is_cookie) ? params[:is_cookie] : true
    args[id]["28"] = params.has_key?(:plugins) ? params[:plugins] : "Chrome PDF Plugin, Chrome PDF Viewer, Native Client"
    args
  end

  def unlock_user(user)
    user.update(locked_at: nil)
  end

  def lock_user(user, time=DateTime.now)
    user.update(locked_at: time)
  end

end