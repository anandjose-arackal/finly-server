# == Schema Information
#
# Table name: quickbooks_categories
#
#  id                                :integer          not null, primary key
#  categories_id                     :integer
#  quickbooks_category_type          :string(255)
#  quickbooks_id                     :string(255)
#  quickbooks_integration_type       :string(255)
#  quickbooks_updated_at             :datetime
#  quickbooks_additional_information :text(16777215)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

class QuickbooksCategory < ActiveRecord::Base

  belongs_to :category

  accepts_nested_attributes_for :category
end
