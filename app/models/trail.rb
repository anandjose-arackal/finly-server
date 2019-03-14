# == Schema Information
#
# Table name: trails
#
#  id                        :integer          not null, primary key
#  parent_id                 :integer
#  parent_type               :string(255)
#  action_user_id            :integer
#  action_id                 :integer
#  action_user_role_id       :integer
#  action_level_id           :integer
#  modified_level_id         :integer
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  delegated_action_user_id  :integer
#  payment_id                :integer
#  original_track_type       :string(255)
#  original_track_id         :integer
#  cash_on_hand_deduction_id :integer
#

class Trail < ApplicationRecord
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :action, optional: true, class_name: 'TrailAction'
  belongs_to :action_user, optional: true, class_name: 'User'
  belongs_to :action_user_role, optional: true, class_name: 'UserRole'
  belongs_to :action_level, optional: true, class_name: 'ReviewalLevel'
  belongs_to :modified_level, optional: true, class_name: 'ReviewalLevel'
  belongs_to :payment, optional: true
  belongs_to :cash_on_hand_deduction, optional: true, class_name: "Payment"
  belongs_to :original_track, polymorphic: true, optional: true

  scope :created_before, -> (time) { where 'created_at < ?', time }

  scope :with_parent, -> (parent_id, parent_type) {
    where(parent_id: parent_id, parent_type: parent_type)
  }

  scope :with_parent_type, -> (parent_type) {
    where(parent_type: parent_type)
  }

  scope :with_action_id, -> (id) {
    where action_id: id
  }

  scope :only_approve, -> {
    where action_id: TrailAction.id_for(:approve)
  }

  scope :only_retract, -> {
    where action_id: TrailAction.id_for(:retract)
  }

  scope :with_action_user_id, -> (id) {
    where(action_user_id: id)
  }

  scope :with_action_user_role_id, -> (role_id) {
    where action_user_role_id: role_id
  }

  # default_scope { order created_at: :desc }

  scope :natural_order, -> {
      reorder :created_at
  }

  scope :desc_order, -> {
    reorder created_at: :desc
  }

  scope :printable_trails, -> {
    action_ids = [TrailAction.id_for(:reject), TrailAction.id_for(:retract)]
    created_at = where(action_id: action_ids).reorder(:created_at).pluck(:created_at).reverse.first
    if created_at.present?
      where('trails.created_at > ?', created_at).reorder(:created_at)
    else
      reorder(:created_at)
    end
  }

  scope :filter_date, -> (date) {
    where created_at: (date.beginning_of_day..date.end_of_day)
  }

  def as_json(user)
    {
        action_type: self.action&.name,
        action_user: self.action_user&.as_json,
        body: generate_trail_body,
        created_at_date: self.created_at.strftime("%d-%b-%Y"),
        created_at_time: self.created_at.strftime("%I:%M%p"),
        created_at: self.created_at,
        note: self.note
    }
  end

  def generate_trail_body(user = nil)
    body = ""
    action_user = User.find_by(id: self.action_user_id)
    if user && action_user && user.id == action_user.id
      user_name = "You"
    else
      user_name = action_user.name rescue nil
      if user_name.nil? && action_id == TrailAction.id_for(:auto_approve)
        user_name = "Your"
      end
    end

    body += user_name

    case self.action_id
      when TrailAction.id_for(:submit)
        action = " submitted"
      when TrailAction.id_for(:reject)
        action = " rejected"
      when TrailAction.id_for(:create)
        action = " created"
      when TrailAction.id_for(:take_control)
        action = " took control"
      when TrailAction.id_for(:update)
        action = " updated"
      when TrailAction.id_for(:approve)
        action = " approved"
      when TrailAction.id_for(:reject)
        action = " rejected"
      when TrailAction.id_for(:retract)
        action = " retracted"
      when TrailAction.id_for(:unapprove)
        action = " unapproved"
      when TrailAction.id_for(:approve_and_forward)
        action = " approved and forwarded"
      when TrailAction.id_for(:auto_approve)
        action = ""
      when TrailAction.id_for(:credited)
        action = " credited"
      when TrailAction.id_for(:settled)
        action = " settled"
      when TrailAction.id_for(:settlement_confirmed)
        action = " confirmed settlement"
      when TrailAction.id_for(:reimbursed)
        action = " reimbursed"
      when TrailAction.id_for(:notify_credit_reimbursement)
        action = ""
      when TrailAction.id_for(:reimbursement_confirmed)
        action = " confirmed reimbursement"
      when TrailAction.id_for(:closed)
        action = " closed"
      when TrailAction.id_for(:void)
        action = " voided"
      when TrailAction.id_for(:send_to_vendor)
        action = " has sent to vendor"
      when TrailAction.id_for(:revision)
        action = " created a revision for this"
      else
        action = ""
    end

    body += action + " the #{self.parent_type}."

    body
  end
end
