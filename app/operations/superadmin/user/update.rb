class Superadmin::User::Update < Superadmin::User::Base

  attr_accessor :user

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def process

  end

end
