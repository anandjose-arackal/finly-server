class Admin::KycProcesses::Users::Export::AsXls < Admin::KycProcesses::Users::Base
  attr_accessor :headers, :contents

  def init
    if !!params&.dig(:download_all)
      individual_kycs_presenter = Admin::KycProcesses::Users::Index.(user, params)
      unless individual_kycs_presenter.success?
        add_message :error, individual_kycs_presenter.messages[:error]
        return
      end
      self.individual_kycs = individual_kycs_presenter.individual_kycs
      return
    end
    super
  end

  def process
    self.headers = [
        'Corporate',
        'Received Date',
        'First Name',
        'Middle Name',
        'Last Name',
        'Date Of Birth',
        'Mothers Maiden Name',
        'Gender',
        'Nationality',
        'Salutation Status',
        'Address Line 1',
        'Address Line 2',
        'Address Line 3',
        'Address Line 4',
        'Residence State',
        'Residence City',
        'Residence Country',
        'Pin Code',
        'Mobile Number',
        'Serial No',
        'Proof Type',
        'Proof Number'
    ]
    self.contents = []
    self.individual_kycs.each do |kyc|
      user = kyc.user
      profile = user.profile
      date = (kyc.submitted_on or Date.today).strftime('%d%m%Y')
      dob = profile.date_of_birth.strftime('%d%m%Y')
      serial_id = kyc&.user&.cards&.first&.proxy
      self.contents << [
          user.company.name,
          date,
          user.first_name,
          nil,
          user.last_name,
          dob,
          user.mothers_maiden_name,
          profile.gender,
          'Indian',
          nil,
          profile.address_1,
          profile.address_2,
          nil,
          nil,
          profile.state.name,
          profile.city,
          'India',
          profile.pin_code,
          user.mobile_number,
          serial_id,
          kyc.type.name,
          kyc.kyc_number
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'assign_card'}, messages)
  end

end