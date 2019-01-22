class RenameIdProofToAddressProof < ActiveRecord::Migration[4.2]
  def change
    remove_attachment :individual_kycs, :pan_card
    add_attachment :individual_kycs, :address_proof
  end
end
