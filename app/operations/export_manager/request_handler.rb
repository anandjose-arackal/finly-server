# Export processor has 5 components

# RequestHandler -> Orchestrator
# Config -> Strategy for getting the configuration
# Master -> Data provider which loads and provides all the necessary data used for generating the export. Can be overridden company-wise
# Generator -> Handles generation of export using config + provider
# Processor -> Email, Direct Download, FTP etc
Dir["#{Rails.root}/app/operations/export_manager/master/**/*.rb"].each {|file| require file}
class ExportManager::RequestHandler < BaseOperation
  attr_accessor :master, :type, :export_job

  class ExportManager::RequestHandler::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :export_job

    def init
      self.export_job = params[:export_job]
    end

  end

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:type].blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
  end

  def init
    self.type = params[:type]
    self.master = init_master
  end

  def validate
    if self.master.blank?
      add_message :error, 'Invalid Type. Error while generating export'
    end
  end

  def process
    master_obj = self.master.new(user, params)
    master_obj.perform
    self.export_job = master_obj.export_job
    self.messages = master_obj.messages
    # result = self.master.new(user, params).perform
    # if result[:success]
    #   if result[:message].present?
    #     add_message :success, result[:message]
    #   end
    #   params[:file_url] = result[:file_url]
    # else
    #   add_message :error, (result[:message] || 'Unknown error')
    # end
  end

  def success
    ExportManager::RequestHandler::SuccessPresenter.new(user, {export_job: export_job}, messages)
  end

  protected

  def init_master
    # Todo fix this to find the valid handler instead of picking the first one. This creates an issue if the user defines 2 exports with the same handler
    ExportManager::Master.subscribers(self.type)&.first
  end


end