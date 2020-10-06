# == Schema Information
#
# Table name: document_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class DocumentStatus < NonTenantedApplicationRecord
  
end
