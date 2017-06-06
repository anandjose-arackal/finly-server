class SyncReport < Integrations::Base

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def process
    
  end
end