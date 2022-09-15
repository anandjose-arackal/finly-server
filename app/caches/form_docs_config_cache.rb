class FormDocsConfigCache < BaseApplicationCache
  attr_accessor :params, :op_result, :op_success

  def initialize(company, current_user, params)
    @company = company
    @current_user = current_user

    @params = params
    @op_success = true

    cache_init
  end

  def self.enabled?
    SaviourCachesToggle.new(@current_user).enabled?
  end

  def self.eager_load?
    true
  end

  def cache_instance_id
    klass_name = Forms::Router.klass(params[:route])&.name
    return "#{klass_name}##{params[:document_id]}"
  end

  def load_data
    @op_result = Forms::Ops::Config.(params: @params, current_user: @current_user)
    @op_success = @op_result.success?

    unless @op_result.success?
      return nil
    end

    result
  end
end

