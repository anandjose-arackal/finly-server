Dir["#{__dir__}/adapters/*.rb"].each { |file| require file }
class ExportManager::Processor < BaseOperation
  attr_accessor :adapter

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:type].blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
  end

  def init
    self.adapter = adapter_for(params)
  end

  def validate
    if self.adapter.blank?
      add_message :error, 'Invalid Type. Error while generating export'
      return
    end
  end

  def process

  end

  protected

  def adapter_for(params)
    adapter = ExportManager::Adapters::BaseAdapter::ADAPTERS[params[:type]]
    if adapter.present?
      return adapter.new(params)
    end
    nil
  end

end