class RenameUserAgreementTrackToCompanyAgreementTrack < ActiveRecord::Migration
  def change
    rename_table :user_agreement_tracks, :company_agreement_tracks
  end
end
