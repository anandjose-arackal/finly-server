class Passbook::Show < BaseOperation
  attr_accessor :users

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init

  end

  def validate

  end

  def process

  end

  protected
  def fetch_users
    self.users = User::Index.(user, params)
    if personal_view?

    end
  end

end