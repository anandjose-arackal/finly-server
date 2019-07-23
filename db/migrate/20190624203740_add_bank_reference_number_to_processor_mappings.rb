class AddBankReferenceNumberToProcessorMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :money_request_processor_mappings, :bank_reference_number, :string
    add_index :money_request_processor_mappings, :bank_reference_number

    add_column :report_processor_group_mappings, :bank_reference_number, :string
    add_index :report_processor_group_mappings, :bank_reference_number
  end
end
