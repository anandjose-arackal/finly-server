class Integrations::Quickbooks::SyncCategories < Integrations::Quickbooks::Base

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid parameters"
    end
  end


  def validate
    # what validation can we have here?
  end


  def process
    # call the Quickbooks adapter method that retrieves the categories from Quickbooks online repo and saves it locally
    categories = adapter.categories
    categories.each do |category|
      category.save
    end
  end

  def post_process
    add_message :success, "Categories successfully synced"
  end

end
