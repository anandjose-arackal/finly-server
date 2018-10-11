# == Schema Information
#
# Table name: export_config_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExportConfigType < ActiveRecord::Base
  include Seedable

  def self.values
    [
        :procurement
    ]
  end

end
