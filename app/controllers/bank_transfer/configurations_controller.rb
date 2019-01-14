class BankTransfer::ConfigurationsController < BaseControllers::PublicBase


  # the below action also returns the list of all categories, custom field configurations as well as TDS Slabs
  def categories_and_cost_centers

  end

  def categories
    @result = Category::Invoice::Index.(current_user, params)
    respond
  end
end
