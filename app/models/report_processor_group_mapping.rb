# == Schema Information
#
# Table name: report_processor_group_mappings
#
#  id                 :integer          not null, primary key
#  processor_group_id :integer          not null
#  user_id            :integer          not null
#  account_id         :integer          not null
#  account_type       :string(255)      not null
#  amount_id          :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ReportProcessorGroupMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :amount
  belongs_to :processor_group, class_name: 'ReportProcessorGroup'
end
