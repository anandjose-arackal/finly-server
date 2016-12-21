class FaqsController < ApplicationController
  def index
    respond_to do |format|
      format.html {render partial: 'faqs'}
    end
  end
end
