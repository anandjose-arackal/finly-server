class AddActionIdToTravelRequestComments < ActiveRecord::Migration
  def change
    add_column :travel_request_comments, :action_id, :integer, references: "TravelRequestCommentAction", foreign_key: true, index: true
  end
end
