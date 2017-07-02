class RenameIdProofToAddressProof < ActiveRecord::Migration
  def change
    remove_attachment :individual_kycs, :pan_card
    add_attachment :individual_kycs, :address_proof
  end
end
