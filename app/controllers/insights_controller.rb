class InsightsController < BaseControllers::WebBase

  def index
    @op = endpoint Insights::Index
  end

  def show
    endpoint Insights::Show do |m|
      m.success {|result| render json: result['result'].as_json}
    end
  end

end
