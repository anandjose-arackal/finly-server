require 'gcm'
class GcmMessenger
  # todo critical to remove this before deploy
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def self.push(users=[], params)
    return unless params[:event_id].present? and params[:message].present?
    gcm_ids = []
    users.each do |user|
      profile = user.profile
      gcm_ids << profile.gcm_sender_id if profile.present? and profile.gcm_sender_id.present?
    end
    gcm_ids.compact!
    # RequestFormatter.clean_hash gcm_ids
    begin
      payload = generate_json_payload params
      gcm = GCM.new("AIzaSyAo-LOXQBqKlAujuV_VzpevSx2itK_350I")
      options = {data: {message: payload}, collapse_key: "updated_score"}
      gcm.send(gcm_ids, options)
    rescue => e
      # logger.error e.message
      # e.backtrace.each { |line| logger.error line }
    end
  end

  private
  def self.generate_json_payload(params)
    type = nil
    type_id = nil
    view = nil
    case params[:event_id]
      when Event.report_submit_id
      when Event.report_approve_id
      when Event.report_retract_id
      when Event.report_reject_id
      when Event.report_comment_id
      when Event.report_reject_expense_id
      when Event.report_take_control_id
      when Event.report_reimbursed_id
        type = 'report'
        type_id = params[:report_id]
        view = params[:view]
      else
    end
    {message: params[:message], type: type, type_id: type_id, view: view}
  end

end