# Export processor has 5 components

# RequestHandler -> Orchestrator
# Config -> Strategy for getting the configuration
# Master -> Data provider which loads and provides all the necessary data used for generating the export. Can be overridden company-wise
# Generator -> Handles generation of export using config + provider
# Processor -> Email, Direct Download, FTP etc
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
      add_message :error, 'Invalid Format. Error while generating export'
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
    ExportManager::Master::BaseMaster.observers.each do |observer|
      return observer if observer.handle == self.type
    end
    nil
  end

  def init_processor
    return nil if self.master.processor.blank?
    self.master.processor.new(user, params, master)
  end

end