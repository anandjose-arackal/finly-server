class AddFinalApproveToCardRequestTrack < ActiveRecord::Migration
  def change
    if Company.count > 0
      CardAssignRequestTrackAction.seed_data
    end
  end
end
