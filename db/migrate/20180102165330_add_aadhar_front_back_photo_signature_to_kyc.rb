class AddAadharFrontBackPhotoSignatureToKyc < ActiveRecord::Migration[4.2]
  def change
    add_attachment :individual_kycs, :aadhar_front
    add_attachment :individual_kycs, :aadhar_back
    add_attachment :individual_kycs, :photo
    add_attachment :individual_kycs, :signature
    add_attachment :individual_kycs, :combined_kyc
  end
end
