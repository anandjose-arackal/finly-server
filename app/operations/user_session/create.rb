# frozen_string_literal: true

class UserSession::Create < BaseOperation
  attr_accessor :response, :user, :status

  def self.call(status, params)
    self.new(status, params).run
  end

  def initialize(status, params)
    super(params[:user], params)
    self.status = status
    self.response = params[:response]
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
      if params[:token].blank?
        add_message :error, 'Token not found'
        return
      end
    end

    if self.params[:username].blank?
      add_message :error, 'Username not found'
      return
    end
  end

  def process
    args = {}
    enrich_user args
    enrich_access args
    enrich_device
    args = {
      user_agent: StringUtils.force_utf_8_encoding(RequestStoreUtil.current_request.user_agent),
      platform: params[:platform],
      app_version: params[:app_version],
      os_version: params[:os_version],
      screen_height: params[:screen_height],
      screen_width: params[:screen_width]
    }
    UserSession.create args
  end

  def enrich_user(args)
    args[:company_id] = user&.company_id
    args[:user_id] = user&.id
    args[:access_token] = params[:response]&.token
    args[:username] = params[:username]
  end

  def enrich_access(args)
    args[:app] = RequestStoreUtil.current_app
    args[:path] = RequestStoreUtil.current_request.path
    args[:method] = RequestStoreUtil.current_request.method_symbol
    args[:controller] = params[:controller]
    args[:action] = params[:action]
    args[:view] = current_view
    args[:started_at] = DateTime.now
    args[:last_request_at] = DateTime.now
  end

  def enrich_request(args)
    args[:referrer] = RequestStoreUtil.current_request.referer
    args[:remote_ip] = RequestStoreUtil.current_request.remote_ip
    args[:landing_page] = RequestStoreUtil.current_request.original_url
  end

  def enrich_user_agent(args)
    ua_client = DeviceDetector.new(RequestStoreUtil.current_request.user_agent)

    args[:user_agent] = StringUtils.force_utf_8_encoding(ua_client.user_agent)

    # TODO: Handle mobile device platform, device name etc

    args[:device] = RequestStoreUtil.current_device
    args[:device_type] = ua_client.device_type
    args[:platform] = ua_client.name
    # args[:app_version] = RequestHeader.app_version
    args[:os_name] = ua_client.os_name

    # Device -> App, Web, API
    # DeviceType -> Desktop, Mobile in case the device is web
    # Platform -> Chrome, OkHTTP, Firefox, iOS HTTP Client
    # App version -> App version
    # OS Name ->iOS, Android, Mac, Windows, Linux
    # OS Version -> OS Version
    # device Screen Height
    # Screen Width
  end

end
