class BbpsBillProviderMigration < ActiveRecord::Migration[5.2]
  # Update all Reviewal Levels & Replicate the same for BbpsBillNonAutofetched
  def change
    ReviewalLevel.where(associated_entity_type: 'BbpsBillProvider').all.each do |rl|
      rl_params = rl.attributes.except("id", "associated_entity_type")
      rl_params["associated_entity_type"] = "BbpsBillNonAutofetchedProvider"
      rl_non_autofetched = ReviewalLevel.create(rl_params)

      rl_non_autofetched.save
      rl.update(associated_entity_type: "BbpsBillAutofetchedProvider")

      # Replicate reviewers
      rl.level_reviewer_mappings.each do |lrm|
        lrm_params = lrm.attributes.except("id", "level_id")
        rl_non_autofetched.level_reviewer_mappings.create(lrm_params)
      end
    end
  end

  # Update DLRM of Utility Bills based on autofetched flag
  DocumentLevelReviewerMapping.where(provider_name: "BbpsBillProvider").each do |dlrm|
    if dlrm.document_reviewer_mappable.present? && dlrm.document_reviewer_mappable.autofetched
      dlrm.update_column(:provider_name, "BbpsBillAutofetchedProvider")
    else
      dlrm.update_column(:provider_name, "BbpsBillNonAutofetchedProvider")
    end
  end
end
