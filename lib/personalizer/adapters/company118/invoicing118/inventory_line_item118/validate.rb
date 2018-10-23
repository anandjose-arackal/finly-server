class Personalizer::Adapters::Company118::Invoicing118::InventoryLineItem118::Validate < Personalizer::Adapters::Base
  attr_accessor :inventory_item_params
  def init
    self.inventory_item_params = op_instance.inventory_item_parameters
  end

  def process
    unless inventory_item_params[:category_id].present?
      add_message :error, 'Please select a category to continue'
    end
  end
end