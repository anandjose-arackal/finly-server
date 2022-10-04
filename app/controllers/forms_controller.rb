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
    # TODO: Remove this part after Cache is enabled and verified for some companies
    # Cache Framework class already takes care of this
    unless SaviourCachesToggle.new(current_user).enabled?
      endpoint Forms::Ops::Config
      return
    end

    custom_cache = FormDocsConfigCache.new(current_user, form_route: params[:document_type], document_id: params[:document_id])
    # value_modifier = -> (cached_value) {
    #   cached_hash = JSON.parse(cached_value)
    #   cached_hash[:created_by] = custom_cache.retrieve_user&.as_json
    #   JSON.generate(cached_hash)
    # }

    through_cache custom_cache do
      endpoint Forms::Ops::Config
      render
    end
  end

  def form_dependencies

    if !(SaviourCachesToggle.new(current_user).enabled?) or params[:ignore_cache]
      endpoint Forms::Ops::Dependencies do |m|
        m.success { |op| render json: op[:dependencies], status: 200 }
      end
      return
    end

    custom_cache = FormDependenciesCache.new(current_user, form_route: params[:route], ignore_cache: params[:ignore_cache])
    through_cache custom_cache do
      endpoint Forms::Ops::Dependencies do |m|
        m.success { |op| render json: op[:dependencies], status: 200 }
      end
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