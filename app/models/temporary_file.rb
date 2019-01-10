# == Schema Information
#
# Table name: temporary_files
#
#  id                :integer          not null, primary key
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :bigint(8)
#  file_updated_at   :datetime
#  expires_on        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class TemporaryFile < ApplicationRecord
  has_attached_file :file
  do_not_validate_attachment_file_type :file
end
