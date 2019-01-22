class AddDocumentNumberConfigsForCompanies < ActiveRecord::Migration[4.2]
  def change
    # Seed DocumentNumberConfigType
    DocumentNumberConfigType.seed_data


    Company.all.each do |company|
      company.document_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), document_number_config_type_id: DocumentNumberConfigType.id_for(:purchase_order)}).save
      company.document_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), document_number_config_type_id: DocumentNumberConfigType.id_for(:inward_document)}).save
    end
  end
end
