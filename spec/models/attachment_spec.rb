# == Schema Information
#
# Table name: attachments
#
#  id                :bigint           not null, primary key
#  resource_id       :integer
#  resource_type     :string(255)
#  file_file_name    :string(255)
#  file_file_size    :decimal(64, 12)
#  file_content_type :string(255)
#  file_updated_at   :datetime
#  company_id        :integer
#  creator_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  description       :text(65535)
#

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
