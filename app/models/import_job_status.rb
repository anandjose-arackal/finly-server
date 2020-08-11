# == Schema Information
#
# Table name: import_job_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ImportJobStatus < ApplicationRecord
  include Seedable

  set_values :pending, :in_progress, :completed, :failed

end
