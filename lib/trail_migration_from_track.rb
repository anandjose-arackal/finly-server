class TrailMigrationFromTrack

  ############################## REPORTS START ##############################
  def self.reports_run
    start_time = DateTime.now
    puts start_time
    reports = Report.all
    remaining_report_ids = reports.pluck(:id) - DocumentLevelReviewerMapping.where(document_reviewer_mappable_type: "Report").pluck(:document_reviewer_mappable_id)
    remaining_reports = Report.where(id: remaining_report_ids)
    # reports = Report.where(id: 25849)
    remaining_reports.each do |report|
      level_number = 1
      policy = report.policy
      levels = policy.levels.where(associated_entity_type: "ReportProvider")
      user = report.user

      # create DLRM for this particular document
      op = ReviewalManager::DocumentReviewalMappings::Set.(report.user, reviewal_document: report)

      report.tracks.each do |track|
        # extract the LURM or LRM for this particular user
        mappings = user.level_user_reviewer_mappings.where(policy_id: policy.id, level_id: levels)
        if mappings.empty?
          mappings = LevelReviewerMapping.where(level_id: levels)
        end

        level = levels.find_by(level_number: level_number)

        reviewer = mappings.where(level_id: level&.id).first&.reviewer

        # now based on the type of track we can decide the attributes to pass to
        # the DLRM creation operation and trails
        trail_action_id = TrailAction.id_for(track.report_tracking_action&.name&.to_sym)
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
        current_dlrm = report.document_level_reviewer_mappings.where(level_id: level&.id)
        current_dlrm.update_all(viewable: true, action_taken_by_id: action_user&.id, taken_control_by_id: taken_control_by&.id) if current_dlrm.pluck(:reviewer_id).include?(action_user&.id)
        next_dlrm = report.document_level_reviewer_mappings.where(level_id: next_level&.id)
        next_dlrm.update_all(viewable: true)
        report.update_columns(controlling_level_id: next_level&.id)


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
        level_number += 1 unless [ReportTrackingAction.id_for(:create), ReportTrackingAction.id_for(:submit)].include?(track.report_tracking_action_id)

        if ReportTrackingAction.ids_for([:reject, :retract]).include?(track.report_tracking_action_id)
          # this will reset the level number because it is going to go through the levels all over again
          level_number = 1
          report.document_level_reviewer_mappings.update_all(action_taken_by_id: nil, taken_control_by_id: nil, action_id: nil, taken_control: false)
        end
      end

      if report.approved? || report.settled? || report.settlement_confirmed?
        report.update_columns(controlling_level_id: nil)
        report.document_level_reviewer_mappings.update_all(viewable: true)
      end
    end
  end
  ############################# REPORTS END ################################

  ############################# PAYMENT TICKET START ##########################
  def self.bpr_run
    bank_payment_requests = BankPaymentRequest.all
    non_api_bank_payment_requests = bank_payment_requests.where.not(api_initiated: true)
    remaining_bank_payment_ids = non_api_bank_payment_requests.pluck(:id) - DocumentLevelReviewerMapping.where(document_reviewer_mappable_type: "BankPaymentRequest").pluck(:document_reviewer_mappable_id)
    remaining_bank_payment_requests = BankPaymentRequest.where(id: remaining_bank_payment_ids)
    # bank_payment_requests = BankPaymentRequest.where(id: [124557])
    remaining_bank_payment_requests.each do |bpr|
      level_number = 1
      policy = bpr.policy
      next if policy.blank?
      levels = policy&.levels.where(associated_entity_type: "BankPaymentRequestProvider")
      user = bpr.user

      # create DLRM for this particular document
      op = ReviewalManager::DocumentReviewalMappings::Set.(bpr.user, reviewal_document: bpr)

      bpr.bank_payment_request_trails.each do |track|
        # extract the LURM or LRM for this particular user
        mappings = user.level_user_reviewer_mappings.where(policy_id: policy.id, level_id: levels)
        if mappings.empty?
          mappings = LevelReviewerMapping.where(level_id: levels)
        end

        level = levels.find_by(level_number: level_number)

        reviewer = mappings.where(level_id: level&.id).first&.reviewer

        # now based on the type of track we can decide the attributes to pass to
        # the DLRM creation operation and trails
        trail_action_id = TrailAction.id_for(track.action&.name&.to_sym)
        original_track = track
        next_level = levels.find_by(level_number: (level_number + 1))
        modified_level = next_level
        action_user = nil
        modified_user = nil
        taken_control_by = nil
        action_user_role_id = UserRole.id_for(:reviewer)
        case track.action_id
          when BankPaymentRequestTrailAction.id_for(:submit), BankPaymentRequestTrailAction.id_for(:retract),
              BankPaymentRequestTrailAction.id_for(:reject), BankPaymentRequestTrailAction.id_for(:unapprove),
              BankPaymentRequestTrailAction.id_for(:approve), BankPaymentRequestTrailAction.id_for(:approve_and_forward)
            action_user = track.action_user
            modified_user = track.modified_user
            modified_level = mappings.where(reviewer_id: modified_user&.id).first&.level
          when BankPaymentRequestTrailAction.id_for(:credit), BankPaymentRequestTrailAction.id_for(:mark_as_credited)
            action_user = track.action_user
            modified_user = nil
            modified_level = nil
            action_user_role_id = track.action_user_role_id
          when BankPaymentRequestTrailAction.id_for(:take_control), BankPaymentRequestTrailAction.id_for(:return_control)
            action_user = track.action_user
            taken_control_by = track.action_user
            modified_user = reviewer
            action_user_role_id = UserRole.id_for(:admin)
          else
            # do nothing?
        end


        # traverse the DLRM and mark the respective ones as viewable if it has touched that user
        current_dlrm = bpr.document_level_reviewer_mappings.where(level_id: level&.id)
        current_dlrm.update_all(viewable: true, action_taken_by_id: action_user&.id, taken_control_by_id: taken_control_by&.id) if current_dlrm.pluck(:reviewer_id).include?(action_user&.id)
        next_dlrm = bpr.document_level_reviewer_mappings.where(level_id: next_level&.id)
        next_dlrm.update_all(viewable: true)
        bpr.update_columns(controlling_level_id: next_level&.id)

        # now creating the trail
        bpr.trails.build(
            action_id: trail_action_id,
            action_user_id: action_user&.id,
            action_user_role_id: action_user_role_id,
            action_level: level,
            modified_level: modified_level,
            original_track: original_track
        ).save

        level_number += 1 unless [BankPaymentRequestTrailAction.id_for(:submit)].include?(track.action_id)

        if BankPaymentRequestTrailAction.ids_for([:reject, :retract]).include?(track.action_id)
          # this will reset the level number because it is going to go through the levels all over again
          level_number = 1
          bpr.document_level_reviewer_mappings.update_all(action_taken_by_id: nil, taken_control_by_id: nil, action_id: nil, taken_control: false)
        end
      end

      begin
        if bpr.approved? || bpr.credited?
          bpr.update_columns(controlling_level_id: nil)
          bpr.document_level_reviewer_mappings.update_all(viewable: true)
        end
      rescue
        bpr.update_columns(controlling_level_id: nil)
        bpr.document_level_reviewer_mappings.update_all(viewable: true)
      end

    end
    end_time = DateTime.now
    puts end_time
  end

  ############################## PAYMENT TICKET START ###########################

  ############################## MONEY REQUEST START ###########################
  def self.money_request_run

  end
  ############################ MONEY REQUEST END ###############################
end
