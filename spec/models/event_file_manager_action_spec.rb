# == Schema Information
#
# Table name: event_file_manager_actions
#
#  id                 :bigint           not null, primary key
#  export_template_id :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_workflow_id  :integer          not null
#

require 'rails_helper'

# RSpec.describe EventFileManagerAction, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
# end
