class GoogleMapsApi::Config < BaseOperation
  attr_accessor :token

  def pre_validate
    return unless user_present? and params_present?
    unless key.present?
      add_message :error, 'Key not found'
      return
    end
  end

  def key
    params[:type]
  end

  def init
    self.token = GoogleMapsConfig.find_by(device: key)&.api_token
  end

  def validate
    if self.token.blank?
      add_message :error, 'Key not found'
      return
    end
  end

  def success
    GoogleMapsApi::Config::Success.new(user, {token: self.token}, messages)
  end

  class GoogleMapsApi::Config::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :token

    def init
      self.token = params[:token]
    end

  end

end