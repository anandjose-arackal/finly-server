# this class takes a report id and returns the ids of ReportTrackingAction that need to be excluded
# for the approval flow chart. These ids will then be used to extract the trails for that particular object
class Reports::ApproveUnapproveBlock < Reports::Base

  attr_accessor :report, :tracks, :response, :approve_id, :unapprove_id

  def init
    id = params[:id] || params[:report_id]
    self.report = Report.find_by(id: id)
    self.tracks = self.report.tracks
    self.approve_id = ReportTrackingAction.id_for(:approve)
    self.unapprove_id = ReportTrackingAction.id_for(:unapprove)
  end

  def validate
    if report.blank?
      add_message :error, "Payment order not found"
    end
  end

  def process
    track_a = []
    track_h = {}
    admin_role_id = UserRole.id_for(:admin)
    self.tracks.each do |track|
      user_id = track.action_user_id
      role_id = track.action_user_role_id
      for_user_id = track.modified_user_id
      for_user_role_id = track.modified_user_role_id
      if track_h[role_id].nil?
        track_h[role_id] = {}
      end
      # All Admin Actions are considered
      # All actions taken for another user are consider ( Take Control )
      # ASSUMPTION: User does not appear twice in the review workflow with the same role
      # If a user appears twice in the approve workflow, then clear everything in the range
      if track_h&.dig(role_id, user_id).present? and for_user_id.blank? and role_id != admin_role_id
        # track has to be truncated as another action from the same user has taken place
        index = track_a.find_index(track_h&.dig(role_id, user_id))
        next if index.nil?
        track_a = track_a[0, index]
        # spurious_ids << track_a[index, track_a.size]
      end
      track_a << track
      track_h[role_id][user_id] = track
    end
    self.response = track_a
  end


  def post_process

  end

  def success
    self.response
  end


end