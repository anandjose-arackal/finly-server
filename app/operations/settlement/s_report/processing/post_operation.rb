class Settlement::SReport::Processing::PostOperation < FinlyPostOperation
  attr_accessor :payment_order, :report_processor_group, :remaining_mappings, :utr, :pending_mappings, :source_account, :completed_mappings

  def pre_validate
    if object.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    case object.class.name
      when PaymentOrder.name
        self.payment_order = object
        self.report_processor_group = ReportProcessorGroup.with_payment_order_id(self.payment_order.id)&.include_mapping_reports.first
      when ReportProcessorGroup.name
        self.report_processor_group = object
      else
        add_message :error, 'Error loading configuration'
        return
    end
  end

  def validate
    if self.report_processor_group.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def pre_process
    if params[:request_ids].present?
      self.pending_mappings = self.report_processor_group.mappings.not_completed.where id: params[:request_ids]
    else
      self.pending_mappings = self.report_processor_group.mappings.not_completed
    end

    self.completed_mappings = self.report_processor_group.mappings.completed

    if self.pending_mappings.blank?
      add_message :error, "No Report found which can be processed."
      return
    end

    self.utr = params[:utr].present? ? params[:utr] : {}
    self.source_account = params[:source_account].present? ? params[:source_account] : {}

    # Since now we can change individual item's status,
    # we check to see if any mappings are remaining to be processed,
    # if so, then we DONT change the entire batch's status
    self.remaining_mappings = self.report_processor_group.mappings.not_completed - self.pending_mappings
  end

  def process
    group_completed_status = ReportProcessorGroupStatus.id_for(:completed)
    group_failed_status = ReportProcessorGroupStatus.id_for(:failed)
    group_partially_complete_status = ReportProcessorGroupStatus.id_for(:partially_completed)
    report_status = ReportStatus.id_for(:settled)
    report_tracking_status = ReportTrackingAction.id_for(:settled)
    trail_action_id = TrailAction.id_for(:settled)
    report_comment_action = ReportCommentAction.id_for(:report_settled)

    has_success = false
    has_failure = false

    marked_as_completed = !!params&.dig(:marked_as_completed)
    marked_as_closed = !!params&.dig(:marked_as_closed)
    update_documents = !!params&.dig(:update_documents)

    if marked_as_closed
      report_status = ReportStatus.id_for(:closed)
      report_tracking_status = ReportTrackingAction.id_for(:closed)
      trail_action_id = TrailAction.id_for(:closed)
      report_comment_action = ReportCommentAction.id_for(:report_closed)
    end

    ReportProcessorGroupMapping.transaction do
      Report.transaction do
        ReportTrack.transaction do
          self.pending_mappings.each do |mapping|
            if marked_as_completed or marked_as_closed or mapping.payment&.completed? or update_documents
              has_success = true
              # mapping.update(status_id: group_completed_status, completed_at: DateTime.now,
              #                marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed)
              # mapping.reports.update_all(controlling_user_id: nil, controlling_user_role_id: nil,
              #                            controlling_for_user_id: nil, controlling_for_user_role_id: nil,
              #                            report_status_id: report_status, reimbursement_id: mapping.payment&.id)


              # todo workflow-v2
              # Updating report status to closed
              # For now not being done through workflow manager as reimbursable_id cannot be updated through it
              # Also version two should handle with multiple items in workflow manager
              # mapping.reports.update_all(controlling_level_id: nil, report_status_id: report_status,
              #                            reimbursement_id: mapping.payment&.id_for)

              if marked_as_closed
                event = 'close'
              else
                event = 'settle'
              end

              update_mapping = true

              mapping.reports.each do |report|

                report.bank_reference_number = self.utr[report.id] if self.utr[report.id].present?
                report.source_account = self.source_account[report.id] if self.source_account[report.id].present?
                report.save if (self.utr[report.id].present? or self.source_account[report.id].present?)

                # temp workaround for satin a*hles
                # if we do not update the utr or source_account, we dont settle the report from update or process template file operation
                # only when the op is called from the mark_as_paid op, we settle the reports

                if update_documents and (report.bank_reference_number.blank? or report.source_account.blank?)
                  update_mapping = false
                  next
                end

                parameters = {
                  document: report,
                  aasm_event: event
                }

                created_by_user = User.find_by id: self.report_processor_group.created_by_user_id
                op = WorkflowManager::Base.(created_by_user, parameters)

                if op.success?
                  # report.tracks.create action_user_id: self.report_processor_group.created_by_user_id,
                  #                    action_user_role_id: self.report_processor_group.created_by_user_role_id,
                  #                    report_tracking_action_id: report_tracking_status,
                  #                    report_status_id: report_status,
                  #                    payment: mapping.payment

                  # Update the trail with payment info
                  op.workflow_output[:trail]&.update(
                    payment_id: mapping.payment&.id,

                  )

                  # report.trails.create action_user_id: self.report_processor_group.created_by_user_id,
                  #                    action_user_role_id: self.report_processor_group.created_by_user_role_id,
                  #                    action_id: trail_action_id,
                  #                    payment: mapping.payment
                  generate_comment(report, mapping, report_comment_action, marked_as_closed)

                end
                

              end

              if update_mapping
                mapping.update(status_id: group_completed_status, completed_at: DateTime.now,
                             marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed)
              end

            elsif mapping.payment&.failed?
              has_failure = true
              mapping.update(status_id: group_failed_status)
            end
          end
        end
      end
    end

    # explicitly settle reports of completed mappings when called from batch level
    # 
    update_mapping_data
    # 

    if self.report_processor_group.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.report_processor_group.processed_amount
    end
    processed_amount.value = self.report_processor_group.payment_order&.amount_processed&.value || self.report_processor_group.total_amount.value
    if has_success and has_failure
      self.report_processor_group.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                         marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed,
                                         processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.present?
      self.report_processor_group.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                         marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed,
                                         processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.blank? and update_documents
      self.report_processor_group.update(status_id: group_partially_complete_status, completed_at: DateTime.now,
                                         marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed,
                                         processed_amount: processed_amount)
    elsif has_success and self.remaining_mappings.blank? and not update_documents
      self.report_processor_group.update(status_id: group_completed_status, completed_at: DateTime.now,
                                         marked_as_completed: marked_as_completed, marked_as_closed: marked_as_closed,
                                         processed_amount: processed_amount)
    elsif has_failure and self.remaining_mappings.blank?
      self.report_processor_group.update(status_id: group_failed_status, processed_amount: processed_amount)
    end
  end

  def generate_comment(report, mapping, report_comment_action, marked_as_closed)
    comment = ''
    unless marked_as_closed
      comment += " via #{self.report_processor_group.payment_type.humanize}"
    end
    if mapping.note.present?
      comment += " with a note '#{mapping.note}'"
    end
    if mapping.payment.present?
      comment += ". Payment ID: #{mapping.payment&.id}"
    end
    report.comments.build(user: self.report_processor_group.created_by_user,
                          report_comment_action_id: report_comment_action, content: comment).save
  end

  def update_mapping_data
    report_comment_action = ReportCommentAction.id_for(:report_settled)
    marked_as_closed = false
    event = 'settle'

    self.completed_mappings.each do |mapping|
      mapping.reports.each do |report|
        next if report.settled? or report.settlement_confirmed? # explicitly settle reports when called from batch level
        parameters = {
            document: report,
            aasm_event: event
        }

        created_by_user = User.find_by id: self.report_processor_group.created_by_user_id
        op = WorkflowManager::Base.(created_by_user, parameters)

        if op.success?
          # Update the trail with payment info
          op.workflow_output[:trail]&.update(payment_id: mapping.payment&.id)
          generate_comment(report, mapping, report_comment_action, marked_as_closed)
        end
      end
    end
  end

end