# == Schema Information
#
# Table name: custom_export_configurations
#
#  id                    :integer          not null, primary key
#  configurable_id       :integer
#  configurable_type     :string(255)
#  custom_report         :boolean
#  custom_invoice        :boolean
#  custom_purchase_order :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class CustomExportConfiguration < ActiveRecord::Base

  belongs_to :configurable, polymorphic: true

end
