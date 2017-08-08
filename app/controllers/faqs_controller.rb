class FaqsController < ApplicationController
  before_action -> { finly_authorize! :web}
  def index
    respond_to do |format|
      format.html {render partial: 'faqs'}
    end
  end
end
