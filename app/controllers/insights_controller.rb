class InsightsController < BaseControllers::WebBase

  def index
    debugger
    endpoint Insights::Index do |m|
      m.success {|result| render json: result['model.index']}
    end
  end

end
