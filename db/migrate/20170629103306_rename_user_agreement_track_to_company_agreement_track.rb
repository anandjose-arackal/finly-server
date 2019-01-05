class RenameUserAgreementTrackToCompanyAgreementTrack < ActiveRecord::Migration[4.2]
  def change
    rename_table :user_agreement_tracks, :company_agreement_tracks
  end
end
