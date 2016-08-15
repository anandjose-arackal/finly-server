class StaticPagesController < ApplicationController
  layout 'static'

  def home
    if logged_in?
      redirect_to reports_path
    end
  end

  def about

  end

end
