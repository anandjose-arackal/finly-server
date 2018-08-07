class PolicyFieldMapping < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :policy

  # validates :field_configuration_id, presence: true
  validates :policy_id, presence: true
end
