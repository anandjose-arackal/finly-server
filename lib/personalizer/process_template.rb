class Personalizer::ProcessTemplate < BaseOperation
  attr_accessor :template

  def pre_validate
    if params&.dig(:template_key).blank?
      add_message :error, 'Template not found'
    end
  end

  def init
    result = Personalizer::ExportTemplates.(current_user)
    if result&.success?
      self.template = result.adapter_for(params[:template_key])
    end
  end

  def validate
    if self.template.blank?
      add_message :error, 'Template not found'
    end
  end

  # This should always return an exporter presenter
  def process
    self.response = self.template.run
  end

end