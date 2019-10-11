# Update UTR and Paid status individually for the iten from the Batch show page
# 
class Settlement::SReport::Processing::Update < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_group, :mapping, :pending_mappings, :request_params

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params.dig(:report_processor_group_mapping, :batch_id).present?
      add_message :error, 'Batch not found'
      return
    end
    if params[:id].blank?
      add_message :error, "Request details not sent"
      return
    end
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.report_processor_group = groups_presenter.report_processor_groups.find_by_id(params.dig(:report_processor_group_mapping, :batch_id))
    unless report_processor_group.present?
      add_message :error, 'Batch not found'
      return
    end
    
    self.mapping = self.report_processor_group.mappings.find_by id: params[:id]
    self.pending_mappings = self.report_processor_group.mappings.not_completed
    self.request_params = mapping_params
  end

  def validate
    if self.mapping.blank? or self.mapping&.cancelled?
      add_message :error, "Request details not found."
      return
    end
  end

  def pre_process
    params[:report_processor_group_mapping].delete(:batch_id)

    if request_params[:reports_attributes].present?
      
      # [ {id: 1, bank_reference_number: "utr", source_account: "source_account"}, {...}, ... ]
      request_params[:reports_attributes].each do |brn|
        unless validate_utr brn[:bank_reference_number]
          add_message :error, "UTR is only allowed to be alphanumberic."
          return
        end

        unless validate_utr brn[:source_account]
          add_message :error, "Source Account is only allowed to be alphanumberic."
          return
        end
      end

      self.mapping.reports.each do |report|
        details = request_params[:reports_attributes].find {|brn| brn if brn[:id].to_i == report.id}
        report.bank_reference_number = details[:bank_reference_number]&.strip if report.bank_reference_number != details[:bank_reference_number]&.strip
        report.source_account = details[:source_account]&.strip if report.source_account != details[:source_account]&.strip
      end

      params[:report_processor_group_mapping].delete(:reports_attributes)

      # if utr is there, we automatically assume the item can be marked as completed
      # request_params[:marked_as_completed] = true
    end

    request_params[:marked_as_completed] = !!StringUtils.to_bool(request_params[:marked_as_completed])

    # flag to make sure, we dont create tracks again if item is already marked completed even if spurious request comes from FE
    request_params[:marked_as_completed] = (self.mapping.completed?) ? false : request_params[:marked_as_completed] 

    if request_params[:marked_as_completed]
      request_params[:status_id] = ReportProcessorGroupStatus.id_for(:completed)
      request_params[:completed_at] = DateTime.now
    end

  end

  def process
    self.mapping.assign_attributes(request_params)
    if self.mapping.valid?
      self.mapping.save
      update_status
      update_mapping_data if request_params[:marked_as_completed] # only update report and its tracks if mapping is not completed
    else
      add_message :error, self.mapping.errors.full_messages
      return
    end

    if self.report_processor_group.completed?
      params[:redirect] = true
    else
      params[:redirect] = false
    end
  end

  def post_process
    add_message :success, 'Updated Successfully'
    # if self.pending_mappings.blank?
    #   add_message :success, "All items credited. Batch status now set to Completed."
    # end
  end

  def success
    Settlement::SReport::Processing::Update::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Processing::Update::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :redirect

    def init
      # Helps to know in frontend if they should redirect to settlement index or simply re-render the same settlement show page
      self.redirect = params[:redirect]
    end
  end

  private

  def mapping_params
    params.require(:report_processor_group_mapping).permit(:bank_reference_number, :marked_as_completed, :completed_at, :status_id, reports_attributes: [:bank_reference_number, :source_account, :id])
  end

  def update_mapping_data
    report_comment_action = ReportCommentAction.id_for(:report_settled)
    marked_as_closed = false
    event = 'settle'

    self.mapping.reports.each do |report|
      
      next if (report.bank_reference_number.blank? and report.source_account.blank?)

      parameters = {
        document: report,
        aasm_event: event
      }

      created_by_user = User.find_by id: self.report_processor_group.created_by_user_id
      op = WorkflowManager::Base.(created_by_user, parameters)

      if op.success?
        # Update the trail with payment info
        op.workflow_output[:trail]&.update(payment_id: self.mapping.payment&.id)
        generate_comment(report, self.mapping, report_comment_action, marked_as_closed)
      end
    end

    update_batch # update the batch status to completed or partially_completed if there are no other pending items left in the batch to be credited.
  end

  def generate_comment(report, mapping, report_comment_action, marked_as_closed)
    comment = ''
    if mapping.note.present?
      comment += " with a note '#{mapping.note}'"
    end
    if mapping.payment.present?
      comment += ". Payment ID: #{mapping.payment&.id}"
    end
    unless marked_as_closed
      comment += " via #{self.report_processor_group.payment_type.humanize}"
    end
    report.comments.build(user: self.report_processor_group.created_by_user,
                          report_comment_action_id: report_comment_action, content: comment).save
  end

  def update_batch
    completed_status = ReportProcessorGroupStatus.id_for(:completed)
    partially_complete_status = ReportProcessorGroupStatus.id_for(:partially_completed)
    self.pending_mappings = self.report_processor_group.mappings.not_completed
    
    # set_status = (self.pending_mappings.blank?) ? completed_status : partially_complete_status
    set_status = partially_complete_status

    if self.report_processor_group.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.report_processor_group.processed_amount
    end
    processed_amount.value = self.report_processor_group.payment_order&.amount_processed&.value || self.report_processor_group.total_amount&.value

    self.report_processor_group.update(status_id: set_status, completed_at: DateTime.now,
                                          marked_as_completed: false,processed_amount: processed_amount)
  end

  def validate_utr(utr)
    return true if utr.blank?
    ( /\A[a-zA-Z0-9]*\Z/.match(utr) ) ? true : false
  end

  def update_status
    return false if self.mapping.completed?

    data = self.mapping.reports.pluck(:bank_reference_number).reject(&:blank?)
    if data.compact.present? and (data.compact.count == self.mapping.reports.count)
      status = ReportProcessorGroupStatus.id_for(:completed)
      self.mapping.update status_id: status
    end
  end
end
