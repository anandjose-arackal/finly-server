class InsightsController < BaseControllers::WebBase

  def index
    endpoint Insights::Index do |m|
      m.success {|result| render json: result['model.index']}
    end
  end

  def show
    endpoint Insights::Show do |m|
      m.success {|result| render json: result['result']}
    end
  end

end
