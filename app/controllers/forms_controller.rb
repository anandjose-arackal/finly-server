class FormsController < BaseControllers::WebBase

  def show
    @op = endpoint Forms::Show do |m|
      m.success {|op| render json: op['model'], status: 200}
    end
  end

end