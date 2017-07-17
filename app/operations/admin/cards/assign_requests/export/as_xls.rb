class Admin::Cards::AssignRequests::Export::AsXls < Admin::Cards::AssignRequests::Base
  attr_accessor :headers, :contents

  def process
    self.headers = ['Email ID', 'Mobile No', 'Disty Name', 'Address 1', 'Address 2', 'DOB', 'Gender', 'State', 'PIN code', 'First Name', 'Last Name', 'Mothers Maiden Name']
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
          user.mothers_maiden_name
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'assign_card'}, messages)
  end

end