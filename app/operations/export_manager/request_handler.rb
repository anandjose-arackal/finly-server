# Export processor has 5 components

# RequestHandler -> Orchestrator
# Config -> Strategy for getting the configuration
# Master -> Data provider which loads and provides all the necessary data used for generating the export. Can be overridden company-wise
# Generator -> Handles generation of export using config + provider
# Processor -> Email, Direct Download, FTP etc
Dir["#{Rails.root}/app/operations/export_manager/master/**/*.rb"].each {|file| require file}
class ExportManager::RequestHandler < BaseOperation
  attr_accessor :master, :type, :processor

  class ExportManager::RequestHandler::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end

  end

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:type].blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
    if params[:export_format].blank?
      add_message :error,'Invalid Format. Error while generating export'
      return
    end
  end

  def init
    self.type = params[:type]
    self.master = init_master
    return if self.master.blank?
    self.processor = init_processor
  end

  def validate
    if self.master.blank? or self.processor.blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
    m = self.master.new(user, params)
    unless m.valid?
      add_message :error, m.errors
      return
    end

  end

  def process
    result = self.processor.run
    if result[:success]
      if result[:message].present?
        add_message :success, result[:message]
      end
      params[:file_url] = result[:file_url]
    else
      add_message :error, (result[:message] || 'Unknown error')
    end
  end

  def success
    ExportManager::RequestHandler::SuccessPresenter.new(user, params, messages)
  end

  protected

  def init_master
    m = ExportManager::Master::BaseMaster::MASTERS[self.params[:type]]
    if m.present?
      return m if m.is_a?(Class)
      return Object.const_get(m)
    end
    nil
  end

  def init_processor
    return nil if self.master.processor.blank?
    self.master.processor.new(user, params, master)
  end

  # def init_config
  #   return {} if self.type.blank?
  #   type = self.params[:type]
  #   fields_arr = self.fields
  #   if fields_arr.size == 1 and fields_arr.first.is_a?(Hash)
  #     fields = fields_arr.first
  #   else
  #     fields = {}
  #     fields_arr.each do |field|
  #       if field.is_a?(Hash)
  #         fields[field.keys.first] = field.values.first
  #       elsif field.is_a?(Symbol)
  #         fields[field] = DEFAULT_CONFIG
  #       end
  #     end
  #   end
  #   company_config = {}
  #   company_config_items = user.company.export_configs.with_field_name(type)
  #   company_config_items&.map {|item| company_config[item[:key]] = {spreadsheet: item[:spreadsheet], pdf: item[:pdf]}}
  #   fields.merge company_config
  # end

end