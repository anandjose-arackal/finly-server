class FormsController < BaseControllers::WebBase

  def show
    @op = endpoint Forms::Show
  end

end
