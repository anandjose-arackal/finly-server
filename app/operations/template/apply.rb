class Template::Apply < Template::Base

  attr_accessor :template, :resource

  def pre_validate
    user_present? and params_present?
    if params[:template].blank?
      add_message :error, 'Error in configuration while loading template'
      return
    end
  end

  def init
    self.resource = params[:resource]
    self.template = params[:template]
  end

  def validate
    unless self.template.respond_to?(:templatable?) and self.template.templatable?
      add_message :error, 'Error creating template. Cannot generate template from the resource'
      return
    end
  end

  def process
    old_resource = nil
    if self.resource.present?
      old_resource = self.resource
    end
    self.resource = self.template.amoeba_dup

    if old_resource.present?
      old_resource.attributes_to_merge&.each do |attribute|
        self.resource.send("#{attribute}=", old_resource.send(attribute))
      end
    end

    unless params[:skip_save]
      unless self.resource.save
        add_message :error, self.template.errors.full_messages
        return
      end
    end
    if old_resource.present?
      old_resource.destroy
    end
  end

  def success
    params[:resource] = self.resource
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