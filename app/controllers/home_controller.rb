class HomeController < ApplicationController
  layout :resolve_layout

  def index
    unless logged_in?
      redirect_to welcome_path
    end
  end

  def welcome
  end

  def about
  end

  private

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
