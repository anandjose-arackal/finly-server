class Masters::Users::Resolver < Resolver::API

  entity User

  def load(params)
    # Since users can only be accessed via admins, only scoping it via application
    user.company.users.with_application(RequestStoreUtil.current_app)
  end

end