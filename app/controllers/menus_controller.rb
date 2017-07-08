class MenusController < ApplicationController

  # todo - temporary, will be changed once new token auth is implemented

  before_action :doorkeeper_authorize!

  def user_menus

  end

  def admin_menus

  end

  def transcriber_menus

  end
end