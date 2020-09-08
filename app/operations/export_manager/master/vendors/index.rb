class ExportManager::Master::Vendors::Index < ExportManager::Builders::Template
  attr_accessor :vendor_ba

  label 'Export'
  description 'Vendor Export'
  export_format 'csv'
  resource 'vendors'
  subscribe 'vendors'
  default true

  attribute :vendor_business_name, template: '{{ record.business_name }}'
  attribute :vendor_trade_name, template: '{{ record.trade_name }}'
  attribute :vendor_id, template: '{{ record.vendor_id }}'
  attribute :name, template: '{{ record.name }}'
  attribute :msme_registered, template: '{{ record.msme_registered }}'
  attribute :msme_registration_number, template: '{{ record.msme_registration_number }}'
  attribute :mobile_number, template: '{{ record.mobile_number }}'
  attribute :email, template: '{{ record.email }}'
  attribute :created_by, template: '{{ record.created_by.name }}'
  attribute :pan, template: '{{ record.pan }}'
  attribute :poc_name, template: '{{ record.gstin_location.poc_name }}'
  attribute :poc_email, template: '{{ record.gstin_location.poc_email }}'
  attribute :gstin_location_address, template: '{{ record.gstin_location.address }}'
  attribute :gstin, template: '{{ record.gstin_location.gstin }}'
  attribute :tds_percentage, template: ''
  attribute :state_code, template: '{{ record.state_code.name }} - {{ record.state_code.code }}'
  attribute :description, template: '{{ record.description }}'
  attribute :vendor_type, template: '{{ record.vendor_type.name }}'
  attribute :default_account_number, template: '{{ record.bank_accounts[0].account_number }}'
  attribute :default_account_name, template: '{{ record.bank_accounts[0].name }}'
  attribute :default_account_ifsc, template: '{{ record.bank_accounts[0].ifsc }}'
  attribute :second_account_number, template: '{{ record.bank_accounts[1].account_number }}'
  attribute :second_account_name, template: '{{ record.bank_accounts[1].name }}'
  attribute :second_account_ifsc, template: '{{ record.bank_accounts[1].ifsc }}'
  attribute :third_account_number, template: '{{ record.bank_accounts[2].account_number }}'
  attribute :third_account_name, template: '{{ record.bank_accounts[2].name }}'
  attribute :third_account_ifsc, template: '{{ record.bank_accounts[2].ifsc }}'
  attribute :fourth_account_number, template: '{{ record.bank_accounts[3].account_number }}'
  attribute :fourth_account_name, template: '{{ record.bank_accounts[3].name }}'
  attribute :fourth_account_ifsc, template: '{{ record.bank_accounts[3].ifsc }}'
  attribute :created_at, template: "{{ record.created_at | date: '%d-%b-%Y' }}"
  attribute :active, template: '{% if record.deactivated %}FALSE{% else %}TRUE{% endif %}'

  # def vendor_business_name(vendor)
  #   vendor.business_name
  # end

  # def vendor_trade_name(vendor)
  #   vendor.trade_name
  # end

  # def vendor_id(vendor)
  #   vendor.vendor_id
  # end

  # def name(vendor)
  #   vendor.name
  # end

  # def msme_registered(vendor)
  #   vendor.msme_registered.to_s
  # end

  # def msme_registration_number(vendor)
  #   vendor.msme_registration_number
  # end

  # def poc_name(vendor)
  #   vendor.gstin_locations&.first&.poc_name
  # end

  # def mobile_number(vendor)
  #   vendor.mobile_number
  # end

  # def email(vendor)
  #   vendor.email
  # end

  # def poc_email(vendor)
  #   vendor.gstin_locations&.first&.poc_email
  # end

  # def created_by(vendor)
  #   vendor.created_by&.name
  # end

  # def pan(vendor)
  #   vendor.pan
  # end

  # def gstin(vendor)
  #   vendor.gstin_locations&.first&.gstin
  # end

  # def state_code(vendor)
  #   vendor.state_code&.full_name
  # end

  # def description(vendor)
  #   vendor.description
  # end

  # def vendor_type(vendor)
  #   vendor.vendor_type&.name
  # end

  # def created_at(vendor)
  #   vendor.created_at.strftime('%d-%m-%Y, %H:%M %z, %A')
  # end

  # def gstin_location_address(vendor)
  #   vendor.gstin_locations&.first&.address
  # end

  # def address(vendor)
  #   vendor.gstin_locations&.first&.address
  # end

  # def gstin_location(vendor)
  #   vendor.gstin_locations&.first&.location
  # end

  # def default_account_number(vendor)
  #   self.vendor_ba = nil if self.vendor_ba != vendor.bank_accounts
  #   self.vendor_ba ||= vendor.bank_accounts

  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
  #   account = self.vendor_ba.first if account.blank?
  #   account&.account_number
  # end

  # def default_account_name(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
  #   account = self.vendor_ba.first if account.blank?
  #   account&.name
  # end

  # def default_account_ifsc(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
  #   account = self.vendor_ba.first if account.blank?
  #   account&.ifsc
  # end

  # def second_account_number(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
  #   account = self.vendor_ba.second if account.blank?
  #   account&.account_number
  # end

  # def second_account_name(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
  #   account = self.vendor_ba.second if account.blank?
  #   account&.name
  # end

  # def second_account_ifsc(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
  #   account = self.vendor_ba.second if account.blank?
  #   account&.ifsc
  # end

  # def third_account_number(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
  #   account = self.vendor_ba.third if account.blank?
  #   account&.account_number
  # end

  # def third_account_name(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
  #   account = self.vendor_ba.third if account.blank?
  #   account&.name
  # end

  # def third_account_ifsc(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
  #   account = self.vendor_ba.third if account.blank?
  #   account&.ifsc
  # end

  # def fourth_account_number(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
  #   account = self.vendor_ba.fourth if account.blank?
  #   account&.account_number
  # end

  # def fourth_account_name(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
  #   account = self.vendor_ba.fourth if account.blank?
  #   account&.name
  # end

  # def fourth_account_ifsc(vendor)
  #   account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
  #   account = self.vendor_ba.fourth if account.blank?
  #   account&.ifsc
  # end

  # def active(vendor)
  #   vendor.deactivated? ? "false" : "true"
  # end

  # def tds_percentage(vendor)
  #   if vendor.vendor_tds_rates.present?
  #     tds_rates_list = vendor.vendor_tds_rates.collect {|vtr| vtr.tds_rates.name + "(#{vtr.tds_rates.tds})"} rescue nil
  #     tds_rates_list.join("| ") rescue nil
  #   end
  # end

end