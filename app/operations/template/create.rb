class Template::Create < Template::Base
  attr_accessor :template, :resource

  def pre_validate
    user_present? and params_present?
    if params[:resource].blank?
      add_message :error, 'Error in configuration while creating template'
      return
    end
    if params[:template_name].blank?
      add_message :error, 'Template name cannot be blank'
      return
    end
  end

  def init
    self.resource = params[:resource]
  end

  def validate
    unless self.resource.respond_to?(:templatable?) and self.resource.templatable?
      add_message :error, 'Error creating template. Cannot generate template from the resource'
      return
    end
  end

  def process
    template_resource = self.resource.amoeba_dup
    template_resource.build_resource_template name: params[:template_name], resource_type: template_resource.class.table_name, user: user
    unless params[:skip_save]
      unless template_resource.save
        add_message :error, self.template.errors.full_messages
        return
      end
    end
  end

  def success
    params[:template] = self.template
    Template::Create::SuccessPresenter.new(user, params, messages)
  end

  class Template::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :template, :resource

    def init
      self.template = params[:template]
      self.resource = params[:resource]
    end

  end

end