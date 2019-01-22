class AddRejectionNoteToTravelRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :rejection_note, :text
  end
end
