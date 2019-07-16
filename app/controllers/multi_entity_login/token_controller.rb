class MultiEntityLogin::TokenController < Oauth::TokenController

  def create
    RequestStore.store[:multi_entity_login] = true
    super()
  end
end