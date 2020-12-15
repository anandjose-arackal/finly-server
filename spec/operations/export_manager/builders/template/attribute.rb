require 'rails_helper'

RSpec.describe ExportManager::Builders::Template::Attribute do  
  context '#build' do
    it 'should return value correctly' do
      obj = ExportManager::Builders::Template::Attribute.new(
        name: 'label_name',
        template: '{{ record.label }}'
      )
      expected = {
        label: 'Label name',
        value: '{{ record.label }}'
      }
      expect(obj.build).to eq expected
    end

    it 'should return value correctly with custom column name' do
      obj = ExportManager::Builders::Template::Attribute.new(
        name: 'label_name',
        template: '{{ record.label }}',
        column_name: 'Label'
      )
      expected = {
        label: 'Label',
        value: '{{ record.label }}'
      }
      expect(obj.build).to eq expected
    end
  end
end