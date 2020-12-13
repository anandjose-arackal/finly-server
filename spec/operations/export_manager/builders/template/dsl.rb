require 'rails_helper'

RSpec.describe ExportManager::Builders::Template::DSL do  
  before :all do
    class TestExport < ExportManager::Builders::Template
      label 'Test label'
      description 'Test Description'
      export_format 'csv'
      resource 'invoice_line_items'
      subscribe 'invoice_line_items'
      default true
      roles [:admin, :finance_manager]
      attribute :invoice_number, template: '{{ record.invoice.invoice_number }}'
      attribute :finly_ref_no, template: '{{ record.invoice.invoice_id }}'
    end
  end

  context '#columns' do
    it 'should return value correctly' do
      expect(TestExport.columns.count).to eq 2
      expect(TestExport.columns.first.name).to eq :invoice_number
      expect(TestExport.columns.first.template).to eq '{{ record.invoice.invoice_number }}'
      expect(TestExport.columns.second.name).to eq :finly_ref_no
      expect(TestExport.columns.second.template).to eq '{{ record.invoice.invoice_id }}'
    end
  end

end
