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
    {token: self.web_hook_track.request_header, body: self.web_hook_track.request_body}
  end

  def header_params
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

end