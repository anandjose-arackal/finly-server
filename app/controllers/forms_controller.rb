class FormsController < BaseControllers::WebBase

  def show
    endpoint Forms::Ops::Show do |m|
      m.success {|op| render json: op['model'], status: 200}
    end
  end

  def form_config
    endpoint Forms::Ops::Config
  end

  def dependency_config
    # endpoint Forms::Ops::DependencyConfig
  end

  def dependency_choice_mapping
    # endpoint Forms::Ops::DependencyConfig
  end

end