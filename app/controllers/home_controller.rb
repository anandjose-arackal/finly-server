class HomeController < BaseControllers::PublicBase
  layout :resolve_layout

  # before_action :check_first_login

  def index
    if signed_in?
      render 'index'
    else
      render 'welcome'
    end
  end

  def landing

  end

  def resources

  end

  def welcome
    if logged_in?
      redirect_to root_path
    end
  end

  def about
  end

  private


  def resolve_layout
    case action_name
    when "index"
      if logged_in?
        "backbone"
      else
        "static"
      end
    when "about", "resources"
      "static"
    when "landing"
      'landing'
    else
      "application"
    end
  end
end
