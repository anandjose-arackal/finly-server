# == Schema Information
#
# Table name: document_messages
#
#  id                        :bigint(8)        not null, primary key
#  order                     :integer
#  user_id                   :integer
#  type_id                   :integer
#  body                      :text(65535)
#  attachment_file_name      :string(255)
#  attachment_content_type   :string(255)
#  attachment_file_size      :bigint(8)
#  attachment_updated_at     :datetime
#  deleted_at                :datetime
#  trashed_at                :datetime
#  messageable_document_id   :integer          not null
#  messageable_document_type :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe DocumentMessage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
