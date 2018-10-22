class Template::Index < Template::Base

  attr_accessor :templates

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.templates = user.resource_templates
  end

  def success
    params[:templates] = self.templates
    Template::Index::SuccessPresenter.new(user, params, messages)
  end

  class Template::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :templates, :paginated_templates

    has_scope :filter_resource_type

    def init
      ScopeUtils.fix_for_scoping(params, :filter_resource_type, :array)
      self.templates = apply_scopes(params[:templates], params)
      page = params[:page]
      per_page = params[:per_page] || 30
      self.paginated_templates = self.templates.paginate(page: page, per_page: per_page)
    end

  end

end