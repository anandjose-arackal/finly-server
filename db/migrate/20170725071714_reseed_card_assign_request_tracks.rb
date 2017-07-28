class ReseedCardAssignRequestTracks < ActiveRecord::Migration
  def change
    CardAssignRequestTrackAction.seed_data
    IndividualKycTrackAction.seed_data
  end
end
