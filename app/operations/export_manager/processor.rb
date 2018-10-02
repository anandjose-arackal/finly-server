Dir["#{__dir__}/adapters/*.rb"].each {|file| require file}
class ExportManager::Processor < BaseOperation
  attr_accessor :adapter

  DEFAULT_CONFIG = {spreadsheet: true, pdf: true}

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:type].blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
  end

  def init
    self.adapter = init_adapter
  end

  def validate
    if self.adapter.blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
  end

  def process
    self.response = self.adapter.generate
  end

  protected

  def init_adapter
    adapter = ExportManager::Adapters::BaseAdapter::ADAPTERS[self.params[:type]]
    if adapter.present?
      return adapter.new(user, params)
    end
    nil
  end


end