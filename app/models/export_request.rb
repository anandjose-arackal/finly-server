# == Schema Information
#
# Table name: export_requests
#
#  id                 :bigint           not null, primary key
#  model_class        :string(255)
#  export_name        :string(255)
#  export_template_id :integer          not null
#  file_file_name     :string(255)
#  file_content_type  :string(255)
#  file_file_size     :bigint
#  file_updated_at    :datetime
#  scheduled_on       :datetime
#  expires_on         :datetime
#  user_id            :integer          not null
#  company_id         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  uuid               :string(36)
#  deleted_at         :datetime
#

class ExportRequest < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :export_template


  has_attached_file :file
  do_not_validate_attachment_file_type :file
end
