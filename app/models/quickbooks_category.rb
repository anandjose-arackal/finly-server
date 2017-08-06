# == Schema Information
#
# Table name: quickbooks_categories
#
#  id                                :integer          not null, primary key
#  category_id                       :integer
#  quickbooks_category_type          :string(255)
#  quickbooks_id                     :string(255)
#  quickbooks_integration_type       :string(255)
#  quickbooks_updated_at             :datetime
#  quickbooks_additional_information :text(16777215)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  company_id                        :integer
#

class QuickbooksCategory < ActiveRecord::Base

  belongs_to :category

  accepts_nested_attributes_for :category

  # to check if its an inventory item, as inventory items need a quantity associated
  def inventory_item?
    data = JSON.parse(self.quickbooks_additional_information)
    if data['type'] == "Inventory"
      return true
    end
  end
end
