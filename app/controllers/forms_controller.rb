class FormsController < BaseControllers::WebBase

  layout :resolve_layout

  unless Rails.env.production?
    around_action :n_plus_one_detection

    def n_plus_one_detection
      Prosopite.scan
      yield
    ensure
      Prosopite.finish
    end
  end

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
    current_user = params[:current_user]

    unless SaviourCachesToggle.new(current_user).enabled?
      endpoint Forms::Ops::Dependencies do |m|
        m.success { |op| render json: op[:dependencies], status: 200 }
      end
      return
    end

    cache_instance = FormDependenciesCache.new current_user.company, current_user, params
    deps = cache_instance.access

    if cache_instance.op_success
      render json: deps, status: 200
    else
      render json: {success: false, messages: cache_instance.op_result.messages.as_json}, status: 422
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

  def form_prediction
    endpoint Forms::Ops::Predict do |m|
      m.success { |result| render json: {prediction: result[:prediction]}, status: 200 }
    end
  end

  def sync_positions
    endpoint Forms::Ops::SyncPositions
  end

  private

  def resolve_layout
    'trailblazers'
  end


end