class User::Track::Login < BaseOperation
  attr_accessor :login_track, :request

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params&.dig(:request).blank?
      add_message :error, 'Request not found'
    end
  end

  def init
    self.request = params[:request]
    request = {
        ip_address: self.request&.remote_ip,
        referrer: self.request&.referrer,
        application: params&.dig(:application)
    }
    self.login_track = user.user_login_tracks.new request
  end

  def validate
    if self.login_track.blank?
      add_message :error, 'Error loading configuration'
      return
    end
    unless self.login_track.valid?
      add_message :error, self.login_track.errors.full_messages
      return
    end
  end

  def process
    self.login_track.save
  end

end