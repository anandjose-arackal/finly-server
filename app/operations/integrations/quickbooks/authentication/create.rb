class Integrations::Quickbooks::Authentication::Create < BaseOperation

  attr_accessor :auth, :user_auth

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.auth = params[:omniauth]
    self.user_auth = user.authentications.where(provider: auth[:provider]).first
  end

  def process
    if user_auth
      unless user_auth.update(uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now)
        add_message :error, user_auth.errors.full_messages
      end
    else
      user_auth = user.authentications.build(provider: auth[:provider], uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now)
      unless user_auth.save
        add_message :error, user_auth.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, "You have successfully linked your Quickbooks account with Finly"
  end
end