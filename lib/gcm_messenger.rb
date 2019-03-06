require 'gcm'
class GcmMessenger
  include Sidekiq::Worker
  # todo critical to remove this before deploy
  require 'openssl'
  unless Rails.env.production?
    OpenSSL::SSL::VERIFY_PEER ||= OpenSSL::SSL::VERIFY_NONE
  end

  def self.push(users, params)
    # self.new.perform_async(users, params)
    gcm_ids = parse_gcm_ids(users)
    return if gcm_ids.blank?
    params[:gcm_ids] = gcm_ids
    self.perform_async(params)
  end

  def perform(params)
    Formatter.symbolize_hash_keys params
    return unless params[:event_id].present? and params[:message].present? and params[:gcm_ids].present?
    gcm_ids = params[:gcm_ids]
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
  def self.parse_gcm_ids(users)
    gcm_ids = []
    users = [users] unless users.is_a?(Array)
    users.each do |user|
      profile = user.profile
      gcm_ids << profile.gcm_sender_id if profile.present? and profile.gcm_sender_id.present?
    end
    gcm_ids.compact!
    gcm_ids
  end

  def generate_json_payload(params)
    payload = {}
    payload[:type] = params[:type]
    payload[:type_id] = params[:type_id] || '0'
    payload[:view] = params[:view]
    payload[:message] = params[:message]
    if params[:type].blank? or params[:type_id].blank?
      case params[:event_id]
        when NotifierType.id_for(:report_submit), NotifierType.id_for(:report_approve), NotifierType.id_for(:report_retract),
            NotifierType.id_for(:report_reject), NotifierType.id_for(:report_comment), NotifierType.id_for(:report_reject_expense),
            NotifierType.id_for(:report_take_control), NotifierType.id_for(:report_reimbursed), NotifierType.id_for(:report_unapprove)
          payload[:type] = 'report'
          payload[:type_id] = params[:report_id]
          payload[:view] = params[:view]
        when NotifierType.id_for(:money_request_submit), NotifierType.id_for(:money_request_approve), NotifierType.id_for(:money_request_retract),
            NotifierType.id_for(:money_request_reject), NotifierType.id_for(:money_request_comment), NotifierType.id_for(:money_request_unapprove),
            NotifierType.id_for(:money_request_take_control)
          payload[:type] = 'money_request'
          payload[:type_id] = params[:money_request_id]
          payload[:view] = params[:view]
        when NotifierType.id_for(:card_transaction)
          payload[:type] = 'card_transaction'
          if params[:atm_withdrawal]
            payload[:sub_type] = 'card_atm_withdrawal'
          elsif params[:expense]
            payload[:sub_type] = 'card_expense'
            payload[:type_id] = params[:expense_id]
          end
        else
      end
    end
    payload
  end

end
