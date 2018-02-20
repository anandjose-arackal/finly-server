require 'security'
class Webhook::Process < Webhook::Base
  attr_accessor :web_hooks, :body, :tracks, :header_params, :event_id, :company

  def pre_validate
    unless params&.dig(:web_hook_event_id).present?
      add_message :error, 'Webhook Event not defined'
      return
    end
    unless params&.dig(:company).present?
      add_message :error, 'Company not found'
      return
    end
    unless params&.dig(:body).present?
      add_message :error, 'Body not found'
      return
    end
  end

  def init
    self.body = params[:body]
    self.company = params[:company]
    self.event_id = params&.dig(:web_hook_event_id)
    self.web_hooks = company.web_hooks.having_event_id(self.event_id)
    self.tracks = []
  end

  def pre_process
    self.web_hooks.each do |web_hook|
      header_params = generate_header_params(web_hook)
      track = web_hook.web_hook_tracks.build(web_hook_event_id: self.event_id, company: self.company, url: web_hook.url,
                                                         request_body: self.body,
                                                         request_header: header_params,
                                                         attempt: 0, last_attempted_at: nil, attempt_success: false)
      track.save
      self.tracks << track
    end
  end

  def process
    if tracks.present?
      tracks.each do |web_hook_track|
        process_web_hook_track(web_hook_track)
      end
    end
  end

  def post_process

  end

  protected
  def process_web_hook_track(web_hook_track)
    WebHookApi::Post.(user, web_hook_track: web_hook_track)
  end

  def generate_header_params(web_hook)
    return nil unless web_hook.secret.present?
    time_created = Time.now.to_i * 1000
    {'msg_mac': Base64.encode64(Security.generate_hmac_hex(web_hook.secret, time_created.to_s)).strip, 'tc': time_created.to_s}
  end

end