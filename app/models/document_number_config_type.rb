# == Schema Information
#
# Table name: document_number_config_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DocumentNumberConfigType < ActiveRecord::Base
  include Seedable

  def self.values
    %i( procurement purchase_order service_order inward_document proforma_invoice delivery_challan e_way_bill bill_of_supply advance_request )
  end
end
