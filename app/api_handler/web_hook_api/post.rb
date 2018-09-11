require 'uri'
class WebHookApi::Post < BaseHandler
  attr_accessor :web_hook_track

  def pre_validate
    unless params&.dig(:web_hook_track).present?
      add_message :error, 'Webhook Track not found'
      return
    end
  end

  def init
    self.web_hook_track = params[:web_hook_track]
    super
  end

  def base_url
    self.web_hook_track.url
  end

  def path
    ''
  end

  def post_params
    {token: self.web_hook_track.request_header, event: web_hook_track.web_hook_event.name, body: self.web_hook_track.request_body}.to_json
  end

  def header_params
    params = { "Content-Type" => "application/json" }
    if self.web_hook_track.web_hook.headers.present?
      headers = self.web_hook_track.web_hook.headers
      params = params.merge(headers)
    end
    return params
  end

  def pre_process
    web_hook_track.update(attempt: 1, last_attempted_at: DateTime.now)
  end

  def parse
    web_hook_track.response_status = self.response.status
    web_hook_track.response_body = self.response.body
    success =(self.response.status.present? and self.response.status == 200)
    web_hook_track.attempt_success = success
    web_hook_track.save
    unless success
      add_message :error, 'API Failed'
      return
    end
  end

  def success
    params[:response] = self.response
    super
  end

  def failure
    params[:response] = self.response
    super
  end

end