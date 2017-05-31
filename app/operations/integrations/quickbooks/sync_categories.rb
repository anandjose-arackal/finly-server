class Integrations::Quickbooks::SyncCategories < Integrations::Base

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def validate

  end

  def process

  end

end