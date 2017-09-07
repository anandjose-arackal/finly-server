class Personalizer::ExportTemplates < BaseOperation
  attr_accessor :company, :company_id, :templates

  def self.call(user)
    self.new(user, nil).run
  end

  def init
    self.company_id = user&.company_id
  end

  def validate
    if company_id.blank?
      add_message :error, 'Company not found'
      return nil
    end
  end

  def process
    file_path = "#{Rails.root}/lib/personalizer/adapters/company#{company_id}/export_templates#{company_id}/config.rb"
    unless File.exists?(file_path)
      add_message :message, 'No personalization applied'
      return nil
    end
    Dir[file_path].each { |f| load f }
    class_name = "Personalizer::Adapters::Company#{company_id}::ExportTemplates#{company_id}::Config"
    self.templates = (Object.const_get(class_name).templates rescue nil)
  end

  def success
    Personalizer::ExportTemplates::SuccessPresenter.new(user, {templates: self.templates}, messages)
  end

  class Personalizer::ExportTemplates::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :templates

    def init
      self.templates = params[:templates]
    end
    
    def has_custom_templates?
      self.templates.present?
    end
    
    def index
      index = []
      self.templates&.each do |key, template|
        index << {name: template[:name], description: template[:description], key: key}
      end
      index
    end

    def show(key)
      if key.is_a?(String)
        key = key.to_sym
      end
      self.templates&.dig(key)
    end

    def adapter_for(key)
      show(key)&.dig(:class).new(user, request_params)
    end

  end

end