require 'rails_helper'

RSpec.describe Company::Setup do
  
  context 'on call' do
    before :all do
      @company1 = create :company
  
      # delete export template added in setup
      ExportTemplateNew.where(company_id: @company1.id).delete_all
      Company::Setup.({company: @company1})
    end
    it 'should add export templates' do
      expect(ExportTemplateNew.where(company_id: @company1.id).present?).to eq true
    end

    it 'should not add duplicate export templates on rerun' do
      count = ExportTemplateNew.where(company_id: @company1.id).count

      # rerun
      Company::Setup.({company: @company1})
      expect(ExportTemplateNew.where(company_id: @company1.id).count).to eq count
    end

    it 'should not update template if modified' do
      export_template = ExportTemplateNew.where(company_id: @company1.id).last
      export_template.modified = true
      export_template.template += ' '
      export_template.save!
      updated_at = export_template.updated_at
      sleep 1

      # rerun
      Company::Setup.({company: @company1})
      expect(ExportTemplateNew.find(export_template.id).updated_at).to eq updated_at
    end

  end
end
