class Api::Fm::V1::TokenController < Oauth::TokenController

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) }

  def create
    super()
  end

  def destroy
    super()
  end

end