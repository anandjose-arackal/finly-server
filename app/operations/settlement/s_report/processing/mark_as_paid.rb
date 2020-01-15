# This settles all reports explicitly even when no details are supplied
# 
class Settlement::SReport::Processing::MarkAsPaid < Settlement::SReport::Processing::Base
  attr_accessor :report_group_processor, :pending_mappings, :completed_mappings

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:report_processor_group_id).present?
      add_message :error, 'Batch not found'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.report_group_processor = groups_presenter.report_processor_groups.find_by_id(params[:report_processor_group_id])
  end

  def validate
    unless report_group_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    unless ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.report_group_processor.status_id)
      add_message :error, 'Batch cannot be Marked as Paid at this stage'
      return
    end
  end

  def pre_process
    self.pending_mappings = self.report_group_processor.mappings.not_completed
    self.completed_mappings = self.report_group_processor.mappings.completed
  end

  def process
    if self.pending_mappings.blank?
      update_batch
      update_mapping_data
      return true
    end

    result = Settlement::SReport::Processing::PostOperation.(self.report_group_processor, {marked_as_completed: true}, true)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, 'Marked as Paid Successfully'
  end

  private

  def update_batch
    completed_status = ReportProcessorGroupStatus.id_for(:completed)

    if self.report_group_processor.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.report_group_processor.processed_amount
    end
    processed_amount.value = self.report_group_processor.payment_order&.amount_processed&.value || self.report_group_processor.total_amount&.value

    self.report_group_processor.update(status_id: completed_status, completed_at: DateTime.now,
                                          marked_as_completed: true,processed_amount: processed_amount)
  end

  def update_mapping_data
    report_comment_action = ReportCommentAction.id_for(:report_settled)
    marked_as_closed = false
    event = 'settle'
    self.completed_mappings.each do |mapping|
      mapping.reports.where.not(status_id: [ReportStatus.settlement_confirmed_id, ReportStatus.settled_id]).each do |report|
        # explicitly settle reports when called from batch level
        parameters = {
          document: report,
          aasm_event: event
        }

        created_by_user = User.find_by id: self.report_group_processor.created_by_user_id
        op = WorkflowManager::Base.(created_by_user, parameters)

        if op.success?
          # Update the trail with payment info
          op.workflow_output[:trail]&.update(payment_id: mapping.payment&.id)
          generate_comment(report, mapping, report_comment_action, marked_as_closed)
        end
      end
    end
  end

  def generate_comment(report, mapping, report_comment_action, marked_as_closed)
    comment = ''
    unless marked_as_closed
      comment += " via #{self.report_group_processor.payment_type.humanize}"
    end
    if mapping.note.present?
      comment += " with a note '#{mapping.note}'"
    end
    if mapping.payment.present?
      comment += ". Payment ID: #{mapping.payment&.id}"
    end
    report.comments.build(user: self.report_group_processor.created_by_user,
                          report_comment_action_id: report_comment_action, content: comment).save
  end

end