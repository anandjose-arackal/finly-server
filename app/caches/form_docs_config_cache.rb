class FormDocsConfigCache < BaseApplicationCache
  attr_accessor :params, :op_result, :op_success

  def initialize(current_user, form_route = nil, document_id = nil, klass_name = nil)
    @document_id = document_id

    if form_route.nil? && klass_name.nil?
      raise ApplicationCacheAccessError.new "FormDependenciesCache needs either form_route or klass_name"
    end

    @form_route = form_route
    if form_route.nil?
      @klass_name = klass_name
    end

    super(current_user)
  end

  def enabled?
    SaviourCachesToggle.new(@current_user).enabled?
  end

  def cache_instance_id
    if !@klass_name.nil?
      klass_name = @klass_name
    else
      klass_name = Forms::Router.klass(@form_route)&.name
    end

    "#{klass_name}"
  end


  def retrieve_user
    # Just to maintain compatibility with non-cached version of the processing
    # Only part which depends on document_id
    # Since we don't want to cache index on document_id, we go this way
    klass = document = nil
    case @form_route
    when "YesBankVendor"
      klass = YesBankVendor
    when "Invoice"
      klass = Invoice
    when "PurchaseOrder"
      klass = PurchaseOrder
    else
      # no nothing
    end

    document = klass.present? && klass.find_by(id: @document_id) if @document_id.present?

    if document.present? && document.created_by.present?
      return document.created_by
    else
      return @current_user
    end
  end

 end

