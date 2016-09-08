class StaticPagesController < ApplicationController
  layout 'static'

  def home
    if logged_in?
      redirect_to home_index_path
    end
  end

  def about

  end

end
