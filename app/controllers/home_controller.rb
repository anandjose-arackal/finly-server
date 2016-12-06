class HomeController < ApplicationController
  layout :resolve_layout

  before_action :check_first_login

  def index
    unless logged_in?
      redirect_to welcome_path
    end
  end

  def welcome
    if logged_in?
      redirect_to root_path
    end
  end

  def about
  end

  private

  def check_first_login
    # code for redirecting to changing default password
    if current_user and current_user.default_password
      redirect_to edit_default_password_path
    end
  end

  def resolve_layout
    case action_name
    when "index"
      "backbone"
    when "welcome", "about"
      "static"
    else
      "application"
    end
  end
end
