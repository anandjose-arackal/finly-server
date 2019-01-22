# == Schema Information
#
# Table name: procurement_tracks
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProcurementTrack < ApplicationRecord
  include Seedable

  def self.values
    %w( on_track chances_of_delay delayed )
  end

end