# == Schema Information
#
# Table name: policy_field_mappings
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  policy_id              :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class PolicyFieldMapping < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :policy

  # validates :field_configuration_id, presence: true
  validates :policy_id, presence: true
end
