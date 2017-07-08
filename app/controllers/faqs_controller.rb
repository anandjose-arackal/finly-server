class FaqsController < ApplicationController
  before_action :doorkeeper_authorize!
  def index
    respond_to do |format|
      format.html {render partial: 'faqs'}
    end
  end
end
