class Docs::UtilityBills::Bills::Mailers::Retract < Docs::UtilityBills::Bills::Mailers::Base

  class Docs::UtilityBills::Bills::Mailers::Retract::RetractedBy < Docs::UtilityBills::Bills::Mailers::Retract

    consumes_event! 'bbps_bills.retract'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have retracted the utility bill #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Retracted"

    assign :sub_header do |user, params|
      "You have retracted the utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Retract::RetractedFrom < Docs::UtilityBills::Bills::Mailers::Retract

    consumes_event! 'bbps_bills.retract'

    assign :to do |user, params|
      record = params[:record]
      last_retract_trail = record.trails.reload.with_action_id(TrailAction.id_for(:retract)).last
      user_ids = record.get_reviewers(last_retract_trail&.action_level_id)&.map(&:id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "#{user.name} has retracted the utility bill #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Retracted"

    assign :title do |user, params|
      "#{user.name} has retracted the utility bill #{params[:record].sequence_id}"
    end
  end
end