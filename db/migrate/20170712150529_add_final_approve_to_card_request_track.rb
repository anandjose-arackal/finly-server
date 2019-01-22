class AddFinalApproveToCardRequestTrack < ActiveRecord::Migration[4.2]
  def change
    if Company.count > 0
      CardAssignRequestTrackAction.seed_data
    end
  end
end
