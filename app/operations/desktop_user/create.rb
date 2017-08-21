class DesktopUser::Create < BaseOperation
  attr_accessor :desktop_user

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params&.dig(:email).blank?
      add_message :error, 'Email cannot be blank'
      return
    end
    if params&.dig(:country).blank?
      add_message :error, 'Country cannot be blank'
      return
    end
  end

  def init
    desktop_user = ::DesktopUser.new(strong_params)
  end

  def validate
    if desktop_user.blank?
      add_message :error, 'Email cannot be blank'
      return
    end
    unless desktop_user.valid?
      add_message :error, desktop_user.errors.full_messages
      return
    end
  end

  def process
    desktop_user.save
  end

  protected
  def strong_params
    params&.permit(:email, :country)
  end

end