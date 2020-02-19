# == Schema Information
#
# Table name: export_job_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

require 'rails_helper'

RSpec.describe ExportJobStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
