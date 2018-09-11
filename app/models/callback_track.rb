# == Schema Information
#
# Table name: callback_tracks
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  request     :string(255)
#  response    :string(255)
#  entity_id   :integer
#  entity_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  success     :boolean
#

class CallbackTrack < ActiveRecord::Base

  belongs_to :company
  belongs_to :entity, polymorphic: true

end
