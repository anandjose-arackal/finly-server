class ReseedCardAssignRequestTracks < ActiveRecord::Migration[4.2]
  def change
    CardAssignRequestTrackAction.seed_data
    IndividualKycTrackAction.seed_data
  end
end
