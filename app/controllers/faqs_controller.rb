class FaqsController < ApplicationController
  allow_oauth!
  def index
    respond_to do |format|
      format.html {render partial: 'faqs'}
    end
  end
end
