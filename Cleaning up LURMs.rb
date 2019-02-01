# policies = Policy.where(id: (460..464).to_a)
policies = Policy.all

policies.each do |policy|
  policy.levels.each do |level|
    # now extracr all the LRMs with a particular threshold, and destroy the ones that are redundant
    # first looping through all the thresholds inside this particular level and looping through them
    thresholds = level.level_reviewer_mappings.pluck(:threshold)
    thresholds.each do |threshold|
      reviewer_ids = level.level_reviewer_mappings.where(threshold: threshold).pluck(:reviewer_id)

      # below will be all LURMs fir this particular level irrespective of a any user
      lurm_reviewer_ids = level.level_user_reviewer_mappings.where(threshold: threshold).pluck(:reviewer_id).uniq

      # this will have all the LURMs that have a single reviewer which is the same reviewer as the LRM - and hence is redundant
      # so all these LURMs will be destroyed
      if lurm_reviewer_ids.count == 1 && reviewer_ids.count == 1 && lurm_reviewer_ids == reviewer_ids
        lurm_with_reviewers = level.level_user_reviewer_mappings.where(threshold: threshold).where(reviewer_id: reviewer_ids)
        lurm_with_reviewers.destroy_all
      end
    end
	end
end