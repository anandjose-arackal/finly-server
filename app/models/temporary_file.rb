# == Schema Information
#
# Table name: temporary_files
#
#  id                :integer          not null, primary key
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :bigint
#  file_updated_at   :datetime
#  expires_on        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :integer
#  company_id        :integer
#

class TemporaryFile < ApplicationRecord
  has_attached_file :file, :use_timestamp => false
  do_not_validate_attachment_file_type :file
end
