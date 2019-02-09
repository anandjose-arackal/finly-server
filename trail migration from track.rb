reports = Report.where.not(report_status_id: Report.status_ids(:open, :auto_approved))
reports = Report.where(id: 7836)
reports.each do |report|
  level_number = 1
  policy = report.policy
  levels = policy.levels.where(associated_entity_type: "ReportProvider")
  user = report.user

  # create DLRM for this particular document
  op = ReviewalManager::DocumentReviewalMappings::Set.(reviewal_document: report)

  report.tracks.each do |track|
    # extract the LURM or LRM for this particular user
    mappings = user.level_user_reviewer_mappings.where(policy_id: policy.id, level_id: levels)
    if mappings.empty?
      mappings = policy.level_reviewer_mappings.where(level_id: levels)
    end


    level = levels.find_by(level_number: level_number)

    reviewer = mappings.where(level_id: level.id).first&.reviewer

    # now based on the type of track we can decide the attributes to pass to
    # the DLRM creation operation and trails
    trail_action_id = TrailAction.id_for(track.report_tracking_action.name.to_sym)
    original_track = track
    next_level = levels.find_by(level_number: (level_number + 1))
    modified_level = next_level
    action_user = nil
    modified_user = nil
    taken_control_by = nil
    action_user_role_id = UserRole.id_for(:reviewer)
    coh_deduction_id = nil
    payment_id = nil
    case track.report_tracking_action_id
      when ReportTrackingAction.id_for(:submit) , ReportTrackingAction.id_for(:retract), ReportTrackingAction.id_for(:reject), ReportTrackingAction.id_for(:create), ReportTrackingAction.id_for(:unapprove), ReportTrackingAction.id_for(:approve)
        action_user = track.action_user
        modified_user = track.modified_user
      when ReportTrackingAction.id_for(:settlement_confirmed), ReportTrackingAction.id_for(:closed)
        action_user = track.action_user
        modified_user = nil
        modified_level = nil
        coh_deduction_id = track.cash_in_hand_deduction_id
      when ReportTrackingAction.id_for(:settled)
        action_user = track.action_user
        modified_user = nil
        modified_level = nil
        action_user_role_id = UserRole.id_for(:finance_manager)
        payment_id = track.payment_id
      when ReportTrackingAction.id_for(:take_control)
        action_user = track.action_user
        taken_control_by = track.action_user
        modified_user = reviewer
        action_user_role_id = UserRole.id_for(:admin)
      when ReportTrackingAction.id_for(:auto_approved)
        action_user = nil
        modified_user = nil
      else
        # do nothing?
    end


    # traverse the DLRM and mark the respective ones as viewable if it has touched that user
    current_dlrm = report.document_level_reviewer_mappings.where(level_id: level.id)
    current_dlrm.update_all(viewable: true, action_taken_by_id: action_user&.id, taken_control_by_id: taken_control_by&.id)

    # now creating the trail
    report.trails.build(
      action_id: trail_action_id,
      action_user_id: action_user&.id,
      action_user_role_id: action_user_role_id,
      action_level: level,
      modified_level: modified_level,
      payment_id: payment_id,
      cash_on_hand_deduction_id: coh_deduction_id,
      original_track: original_track
    ).save

    # incrementing the level number so that the next one will be at the level that is next
    level_number += 1 unless track.report_tracking_action_id == ReportTrackingAction.id_for(:create)

    if ReportTrackingAction.ids_for([:reject, :retract]).include?(track.report_tracking_action_id)
      # this will reset the level number because it is going to go through the levels all over again
      level_number = 1
    end
  end
end