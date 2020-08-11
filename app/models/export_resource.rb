# == Schema Information
#
# Table name: export_resources
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  value      :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExportResource < ApplicationRecord
  RESOURCES = [
    {
      name: 'Invoice Line Items',
      value: 'invoice_line_items'
    }
  ]

  def self.seed_data
    RESOURCES.each do |resource|
      next if ExportResource.find_by(value: resource[:value]).present?

      ExportResource.create(name: resource[:name], value: resource[:value])
    end
  end
end
