# this operation will extract all the approvers of a Bank Payment Request till a particular user (i.e. the controlling user)
# If not controlling user is passed, it retrieves all users in the chain
class Reports::Approvers < Reports::Base

  attr_accessor :approvers, :bank_payment_request, :till_user, :reviewer, :reviewer_role

  class Reports::Approvers::ApproversPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :approvers

    def init
      self.approvers = params[:approvers]
    end

  end

  def authorized_user_types
    nil
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def initialize(params = {})
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def self.call(params = {})
    self.new(params).run
  end

  def init
    self.report = params[:report]
    self.user = self.report.user
    self.approvers = []
  end

  def validate
    if self.report.blank?
      add_message :error, "Expense Report not Found"
    end
  end

  def process
    # run a loop till the next_reviewer is the current user
    self.reviewer = report.user
    self.reviewer_role = UserRole.id_for(:employee)

    op = User::Team::Review::NextReviewer.(report, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)
    first_reviewer = op.user

    # checking if the particular payment order can be auto approved
    if first_reviewer.blank?
      self.approvers << {
          controlling_user: report.can_submit?,
          action_id: nil,
          owner: true,
          action_user: {
              name: report.user.name,
              email: report.user.email,
              mobile_number: report.user.mobile_number
          },
          role: {
              id: UserRole.id_for(:employee),
              name: UserRole.name_for(UserRole.id_for(:employee))
          },
          auto_approve: true,
          title: "This expense Report order will be auto approved as there is no reviewer assigned"
      }
      return
    end

    # # now extract all the users from the track
    tracks = Reports::ApproveUnapproveBlock.(user, id: report.id)
    tracks.each do |track|
      next if track.report_tracking_action_id == 1
      self.approvers << {
          action_id: track.report_tracking_action_id,
          controlling_user: false,
          action_user: {
              name: track.action_user&.name,
              email: track.action_user&.email,
              mobile_number: track.action_user&.mobile_number,
          },
          role: {
              id: track.action_user_role_id,
              name: UserRole.name_for(track.action_user_role_id)
          }
      }
      self.reviewer = track.action_user
      self.reviewer_role = track.action_user_role_id
    end

    #adding the controlling user of the particular bank payment request if they're present
    if report.controlling_user.present?
      self.approvers << {
          action_id: nil,
          controlling_user: true,
          owner: (report.controlling_user_id == report.user&.id),
          action_user: {
              name: report.controlling_user&.name,
              email: report.controlling_user&.email,
              mobile_number: report.controlling_user&.mobile_number,
          },
          role: {
              id: report.controlling_user_role_id,
              name: UserRole.name_for(report.controlling_user_role_id)
          }
      }
    end
    self.reviewer = report.controlling_for_user || report.controlling_user
    self.reviewer_role = report.controlling_for_user_role_id

    #now extracting all pending approvers (assuming there's not take control action here)
    op = User::Team::Review::NextReviewer.(report, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)

    self.reviewer = op.user
    self.reviewer_role = op.success? ? op.role_id : nil

    reviewer_ids = {}
    while self.reviewer.present? && (reviewer_ids[self.reviewer_role].blank? or !reviewer_ids[self.reviewer_role].include?(self.reviewer&.id))
      self.approvers << {
          controlling_user: (self.reviewer.id == report.controlling_user_id and self.reviewer_role == report.controlling_user_role_id),
          rejected: false,
          action_user: {
              name: self.reviewer.name,
              email: self.reviewer.email,
              mobile_number: self.reviewer.mobile_number
          },
          role: {
              id: self.reviewer_role,
              name: UserRole.name_for(self.reviewer_role)
          },
          title: "",
          timestamp: (report.approved? ? report.approved_at : nil)
      }

      if reviewer_ids[self.reviewer_role].nil?
        reviewer_ids[self.reviewer_role]= []
      end
      # adding this reviewer to the list of previous reviewers
      reviewer_ids[self.reviewer_role] << self.reviewer&.id
      op = User::Team::Review::NextReviewer.(report, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)
      self.reviewer = op.user
      self.reviewer_role = op.role_id
    end
  end

  def success
    params[:approvers] = self.approvers
    self.approvers
    Reports::Approvers::ApproversPresenter.new(user, params, messages)
  end
end