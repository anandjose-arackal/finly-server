# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean          default(TRUE), not null
#  base_currency_id :integer          default(1)
#  status_id        :integer          default(1), not null
#  test_account     :boolean          default(FALSE)
#  subdomain        :string(255)
#  group_id         :integer
#  deleted_at       :datetime
#
require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'on create' do
    it 'should add export templates' do
      company1 = create :company
      expect(ExportTemplateNew.where(company_id: company1.id).present?).to eq true
    end
  end
end
