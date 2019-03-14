class NavBarController < ApplicationController

  before_action -> { finly_authorize! :web }

  def show
    @result = Navbar::Config.(current_user, params)
    respond
  end

end
