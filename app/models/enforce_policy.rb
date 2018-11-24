# == Schema Information
#
# Table name: enforce_policies
#
#  id               :integer          not null, primary key
#  enabled          :boolean
#  enforceable_id   :integer
#  enforceable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class EnforcePolicy < ActiveRecord::Base

  belongs_to :enforceable, polymorphic: true
end
