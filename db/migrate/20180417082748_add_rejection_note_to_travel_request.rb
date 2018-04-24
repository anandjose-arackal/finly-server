class AddRejectionNoteToTravelRequest < ActiveRecord::Migration
  def change
    add_column :travel_requests, :rejection_note, :text
  end
end
