class FaqsController < BaseControllers::WebBase
  def index
    respond_to do |format|
      format.html {render partial: 'faqs'}
    end
  end
end
