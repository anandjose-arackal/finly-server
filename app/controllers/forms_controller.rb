class FormsController < BaseControllers::WebBase

  def show
    endpoint Forms::Ops::Show do |m|
      m.success { |op| render json: op['model'], status: 200 }
    end
  end

  def form_config
    endpoint Forms::Ops::Config
  end

  def form_dependency_config
    endpoint Forms::Ops::Config
  end

  def form_entity_choices
    endpoint Forms::Ops::Choices do |m|
      m.success { |result| render json: result[:choices] }
    end
  end

  def form_conditions
    endpoint Forms::Ops::Conditions do |m|
      m.success { |op| render json: op[:conditions], status: 200 }
    end
  end

  def form_validations
    endpoint Forms::Ops::Validations do |m|
      m.success { |op| render json: op[:validations], status: 200 }
    end
  end

end