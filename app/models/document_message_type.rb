# == Schema Information
#
# Table name: document_message_types
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentMessageType < ApplicationRecord
  include Seedable

  def self.values
    [:conversation, :notice]
  end

end
