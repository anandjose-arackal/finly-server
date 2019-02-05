Report.where.not(report_status_id: Report.status_ids(:open, :auto_approved)).each do |report|
  level_number = 1
  policy = report.policy
  levels = policy.levels.where(associated_entity_type: "ReportProvider")

  # # create the trail for creation
  # report.trails.build(
  #     action_id: TrailAction.id_for(:create),
  #     action_user_id: report.user_id,
  #     action_user_role_id: UserRole.id_for(:employee),
  #     action_level: nil,
  #     modified_level_id: level.id,
  #     original_track: report.tracks.first
  # ).save

  report.tracks.each do |track|
    # extract the LURM or LRM for this particular user
    mappings = user.level_user_reviewer_mappings.where(policy_id: policy.id, level_id: levels)
    if mappings.empty?
      mappings = policy.level_reviewer_mappings.where(level_id: levels)
    end
    level = levels.find_by(level_number: level_number)

    reviewer = mappings.where(level_id: level.id).first.reviewer

    # now based on the type of track we can decide the attributes to pass to
    # the DLRM creation operation and
    case track.action_id
      when ReportTrackingAction.ids_for(:submit, :retract, :reject, :create, :unapprove)
        trail_action_id = TrailAction.id_for(track.report_tracking_action.name.to_sym)
        action_user = track.action_user
        modified_user = track.modified_user
        modified_level = mappings.where(reviewer_id: modified_user.id).first.level
        original_track = track
    end

    # now based on the track the remaining trails will be created
    report.document_level_reviewer_mappings.build(
      policy_id: policy.id,
      level_id: level.id,
      reviewer_id: reviewer.id
    )

    # incrementing the level number so that the next one will be at the level that is next


    if ReportTrackingAction.ids_for([:reject, :retract]).include?(track.tracking_action_id)
      # this will reset the level number because it is going to go through the levels all over again
      level_number = 1
    end
  end
end