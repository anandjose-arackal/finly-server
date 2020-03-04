# == Schema Information
#
# Table name: export_jobs
#
#  id                      :bigint           not null, primary key
#  name                    :string(255)      not null
#  export_type             :string(255)
#  created_by_id           :integer
#  company_id              :bigint           not null
#  request_params          :text(4294967295)
#  completed_at            :datetime
#  total_records           :integer
#  completed_records       :integer
#  completion_percentage   :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status_id               :integer          not null
#  deleted_at              :datetime
#  master                  :string(255)
#  description             :string(255)
#  record_type             :string(255)
#  record_id               :bigint
#  crash_stacktrace        :text(65535)
#  message                 :text(65535)
#  note                    :text(65535)
#

require 'rails_helper'

RSpec.describe ExportJob, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
