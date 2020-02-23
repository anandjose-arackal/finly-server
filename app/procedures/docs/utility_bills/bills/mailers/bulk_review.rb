class Docs::UtilityBills::Bills::Mailers::BulkReview < Docs::UtilityBills::Bills::Mailers::Base

  # consumes_event! 'bbps_biller_subscription.approve'

  assign :tables do |user, params|
    tables = []
    tables.push(Docs::UtilityBills::Bills::Mailers::TableBulk.(params[:result]))
    tables.flatten
  end

  assign :hero_bg_icon, "icon_bbps_bill"

  assign :company do |user, params|
    company_id = user.company_id
    company = Company.find company_id
    company = {
        logo_url: company.configuration.logo.url(:thumb),
        name: company.name
    }
  end

  assign :to do |user, params|
    [user.email]
  end

  assign :hero_bg_image, "bg_default"

  assign :subject do |user, params|
    action_type = params[:action_type] || "action"
    action_type = action_type.humanize.split(" ").map(&:capitalize).join(" ")
    "Bulk #{action_type} Operation"
  end

  assign :title do |user, params|
    action_type = params["action_type"] || "action"
    action_type = action_type.humanize.split(" ").map(&:capitalize).join(" ")
    "Bulk #{action_type} for Utility Bills"
  end

  assign :sub_header do |user, params|
    action_type = params["action_type"] || "action"
    action_type = action_type.humanize.split(" ").map(&:capitalize).join(" ")
    datetime = DateUtils.parse_datetime(params["performed_at"])
    "Result for Bulk #{action_type} performed at #{datetime.strftime("%I:%M %p, %d %b %Y")}"
  end
end