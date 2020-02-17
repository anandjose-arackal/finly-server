class Personalizer::ProcessTemplate < BaseOperation
  attr_accessor :template, :export_file_path

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
    self.export_file_path = self.response&.file_url
  end

  def success
    params[:file_url] = export_file_path
    Personalizer::ProcessTemplate::FilePresenter.new(user, params, messages)
  end

  class Personalizer::ProcessTemplate::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

end