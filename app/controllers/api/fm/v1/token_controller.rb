class Api::Fm::V1::TokenController < Oauth::TokenController

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) }

  def create
    super()
    unless @auth_grant and @auth_grant&.user.company_admin?
      head 401
    end
  end

  def destroy
    super()
  end

end