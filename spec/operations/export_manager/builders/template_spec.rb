require 'rails_helper'

RSpec.describe ExportManager::Builders::Template do  
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

  context '#master' do
    it 'should return value correctly' do
      expect(TestExport.master).to eq 'TestExport'
    end
  end

  context '#build' do
    it 'should build template correctly' do
      expected_value = {
        name: 'Test label',
        description: 'Test Description',
        resource: 'invoice_line_items',
        export_format: 'csv',
        template: '{"columns":[{"label":"Invoice number","value":"{{ record.invoice.invoice_number }}"},{"label":"Finly ref no","value":"{{ record.invoice.invoice_id }}"}]}',
        query: {},
        default: true,
        master: 'TestExport',
        personal: false,
        user_roles: [{
          "user_role_id": UserRole.id_for(:admin)
        },{
          "user_role_id": UserRole.id_for(:finance_manager)
        }]
      }
      expect(TestExport.build).to eq expected_value
    end
  end

  context '#update_template!' do
    it 'should update template for all companies' do
      @company1 = create :company
      export_template = ExportTemplateNew.where(company_id: @company1.id, master: 'TestExport').last
      export_template.template = 'reset template'
      export_template.save!

      TestExport.update_template!
      expect(ExportTemplateNew.find(export_template.id).template).to eq TestExport.build[:template]
    end
  end
end
