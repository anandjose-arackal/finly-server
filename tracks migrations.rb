############# REPORT TRACK MIGRATION ##############
# first recreating the trails for all approves, settled, settlement confirmed and closed reports
Report.where(report_status_id: [ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]).each do |report|
	policy = Policy.unscoped.find_by(id: report.policy_id)
	report_levels = policy.levels.where(associated_entity_type: "ReportProvider")
	report_levels.each do |level|
		level.level_user_reviewer_mappings.each do |lurm|
			reviewer = lurm.reviewer
			dlrm = report.document_level_reviewer_mappings.build(
				policy: policy,
				level: level,
				level_number: level.level_number,
				viewable: true,
				become_viewable_at: DateTime.now,
				provider_name: report.get_default_provider,
				reviewer: reviewer,
				action_taken_by: reviewer,
				action: TrailAction.id_for(:approve)
				)
			dlrm.save
		end
	end

	# now creating the trails in the new system so that the trails will reflect in the new system
	# not considering modified user in this
	report.tracks.each do |track|
		action_user = track.action_user
		modified_user = track.modified_user
		reviewal_level = nil
		# now find this particular user in the first level that he / she appears in the reviewal chain
		report.policy.levels.each do |level|
			if level.level_user_reviewer_mappings.find_by(reviewer_id: action_user.id).present?
				reviewal_level = level
				break
			end
		end
		action_id = track.report_tracking_action_id
		action = ReportTrackingAction.find_by(id: action_id)
		case action_id
			when ReportTrackingAction.id_for(:approve), ReportTrackingAction.id_for(:submit), ReportTrackingAction.id_for(:create), ReportTrackingAction.id_for(:auto_approve), 
				ReportTrackingAction.id_for(:reject), ReportTrackingAction.id_for(:unapprove)
				trail - report.trails.create(
					action_user_id: action_user&.id,
					action_level: reviewal_level,
					action_user_role: UserRole.id_for(:reviewer),
					action_id: TrailAction.id_for(action&.name&.to_sym)
				)	
				trail.save
			when ReportTrackingAction.id_for(:settled), ReportTrackingAction.id_for(:settlement_confirmed), ReportTrackingAction.id_for(:closed)
				trail = report.trails.create(
					action_user_id: action_user&.id,
					action_level: reviewal_level,
					action_user_role: UserRole.id_for(:finance_manager),
					action_id: TrailAction.id_for(action&.name&.to_sym)
					)
				trail.save
			when ReportTrackingAction.id_for(:take_control)
				trail = report.trails.create(
					action_user_id: action_user&.id,
					action_level: reviewal_level,
					action_user_role: UserRole.id_for(:admin),
					action_id: TrailAction.id_for(action&.name&.to_sym)
					)
				trail.save
			else
				# do nothing?
		end
	end
end

# now executing for reports that are open
Report.where(report_status_id: ReportStatus.id_for(:open)).each do |report|

end


############# MONEY REQUEST ###############
