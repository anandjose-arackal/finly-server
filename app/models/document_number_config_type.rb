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

class DocumentNumberConfigType < ApplicationRecord
  include Seedable

  # After adding more items here seed and also create DocumentNumberConfig for all existing companies like this:
  # company.document_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), document_number_config_type_id: DocumentNumberConfigType.id_for(:inward_document)}).save
  def self.values
    %i( purchase_order inward_document )
  end
end
