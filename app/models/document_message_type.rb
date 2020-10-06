# == Schema Information
#
# Table name: document_message_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class DocumentMessageType < NonTenantedApplicationRecord
  include Seedable

  def self.values
    [:conversation, :notice]
  end

end
