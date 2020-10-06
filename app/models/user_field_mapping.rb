# == Schema Information
#
# Table name: user_field_mappings
#
#  id                     :bigint           not null, primary key
#  user_id                :integer
#  field_configuration_id :integer
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class UserFieldMapping < ApplicationRecord
  include SoftDeletable

  belongs_to :company, optional: true
  belongs_to :user
  belongs_to :field_configuration
end