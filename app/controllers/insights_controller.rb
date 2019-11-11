class InsightsController < BaseControllers::WebBase

  def index
    begin
      endpoint Insights::Index do |m|
        m.success { |result| render json: result }
      end
    rescue => exception
      puts 'TEST CHECK'
      puts exception.backtrace
    end
  end

  def show
    endpoint Insights::Show do |m|
      m.success { |result| render json: result['result'] }
    end
  end

end
