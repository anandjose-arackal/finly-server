class FormsController < BaseControllers::WebBase

  # Form Renderer
  # def show
  #   endpoint Forms::Ops::Show do |m|
  #     m.success { |op| render json: op['model'], status: 200 }
  #   end
  # end

  # Used in form builder
  def show
    endpoint Forms::Ops::Show
  end

  def index
    endpoint Forms::Ops::Index
  end

  def form_config
    endpoint Forms::Ops::Config
  end

  def form_dependencies
    endpoint Forms::Ops::Dependencies do |m|
      m.success { |op| render json: op[:dependencies], status: 200 }
    end
  end

  def form_entity_choices
    endpoint Forms::Ops::Choices do |m|
      m.success { |result| render json: result[:choices].as_json, status: 200 }
    end
  end

  def form_lookup_details
    endpoint Forms::Ops::LookupDetails do |m|
      m.success { |result| render json: {data: result[:data]}, status: 200 }
    end
  end



end