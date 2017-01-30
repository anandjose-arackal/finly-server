# == Schema Information
#
# Table name: enforce_policies
#
#  id               :integer          not null, primary key
#  enforceable_id   :integer          not null
#  enforceable_type :string(255)      not null
#  enabled          :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class EnforcePolicy < ActiveRecord::Base

  belongs_to :enforceable, polymorphic: true
end
