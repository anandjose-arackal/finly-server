class NavBarController < BaseControllers::WebBase

  def show
    @result = Navbar::Config.(current_user, params)
    respond
  end

end
