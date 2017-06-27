module FinlyIntegrations
  extend self

  module Adapters
  end

  def adapter
    return @adapter if @adapter
    raise 'No adapter initialized'
  end

  def adapter=(adapter)
    return @adapter = FinlyIntegrations::Adapters.const_get("#{adapter.to_s.capitalize}Adapter").new if FinlyIntegrationsConstants::ADAPTERS_LIST.include? adapter
    raise 'Requested Adapter not found'
  end
end