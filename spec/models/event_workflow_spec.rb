# == Schema Information
#
# Table name: event_workflows
#
#  id                :bigint           not null, primary key
#  model_class       :string(255)      not null
#  trigger_type      :string(255)      not null
#  event_key         :string(255)
#  personal          :boolean          default(TRUE)
#  user_id           :integer          not null
#  company_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string(255)      not null
#  description       :text(65535)      not null
#  conditions        :text(65535)
#  event_schedule_id :integer
#

require 'rails_helper'

RSpec.describe EventWorkflow, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
