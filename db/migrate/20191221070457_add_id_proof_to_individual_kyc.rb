class AddIdProofToIndividualKyc < ActiveRecord::Migration[5.2]
  def change
    remove_attachment :individual_kycs, :id_proof
    add_attachment :individual_kycs, :id_proof_front
    add_attachment :individual_kycs, :id_proof_back
  end
end
