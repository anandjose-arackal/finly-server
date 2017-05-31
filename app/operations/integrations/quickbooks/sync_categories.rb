class Integrations::Quickbooks::SyncCategories < Integrations::Base

  attr_accessor :company

  def initialize(company, params)

  end

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
    # call the Quickbooks adapter method that retrieves the categories from Quickbooks online repo and saves it locally
  end

end