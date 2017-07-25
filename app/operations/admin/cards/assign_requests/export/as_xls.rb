class Admin::Cards::AssignRequests::Export::AsXls < Admin::Cards::AssignRequests::Base
  attr_accessor :headers, :contents

  def init
    if !!params&.dig(:download_all)
      assign_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
      unless assign_requests_presenter.success?
        add_message :error, assign_requests_presenter.messages[:error]
        return
      end
      self.card_assign_requests = assign_requests_presenter.card_assign_requests
      return
    end
    super
  end


  def process
    self.headers = ['Email ID', 'Mobile No', 'Disty Name', 'Address 1', 'Address 2', 'DOB', 'Gender', 'State', 'PIN code', 'First Name', 'Last Name', 'Mothers Maiden Name', 'Serial ID', 'KYC Type', 'Kyc Number']
    self.contents = []
    self.card_assign_requests.each do |card_assign_request|
      user = card_assign_request.card_owner
      profile = user.profile
      self.contents << [
          user.email,
          user.mobile_number,
          nil,
          profile.address_1,
          profile.address_2,
          profile.date_of_birth,
          profile.gender,
          profile.state.name,
          profile.pin_code,
          user.first_name,
          user.last_name,
          user.mothers_maiden_name,
          card_assign_request.card.proxy,
          user&.individual_kyc&.type&.name,
          user&.individual_kyc&.kyc_number
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'assign_card'}, messages)
  end

end