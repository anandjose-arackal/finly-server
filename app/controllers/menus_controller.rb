class MenusController < ApplicationController

  # todo - temporary, will be changed once new token auth is implemented
  before_action :authenticate_user!
  allow_oauth!

  def user_menus

  end

  def admin_menus

  end

  def transcriber_menus

  end
end