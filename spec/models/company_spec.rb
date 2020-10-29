require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'on create' do
    it 'should add export templates' do
      company1 = create :company
      expect(ExportTemplateNew.where(company_id: company1.id).present?).to eq true
    end
  end
end
