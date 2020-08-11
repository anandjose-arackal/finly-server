# == Schema Information
#
# Table name: export_formats
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  value      :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExportFormat < ApplicationRecord
  FORMATS = [
    {
      name: 'Excel',
      value: 'xls'
    },
    {
      name: 'CSV',
      value: 'csv'
    },
    {
      name: 'JSON',
      value: 'json'
    },
    {
      name: 'XML',
      value: 'xml'
    },
    {
      name: 'Others',
      value: 'other'
    }
  ]

  def self.seed_data
    FORMATS.each do |format|
      next if ExportFormat.find_by(value: format[:value]).present?

      ExportFormat.create(name: format[:name], value: format[:value])
    end
  end
end
