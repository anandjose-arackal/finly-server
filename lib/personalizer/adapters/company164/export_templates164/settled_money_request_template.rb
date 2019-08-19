class Personalizer::Adapters::Company164::ExportTemplates164::SettledMoneyRequestTemplate < Personalizer::Adapters::ExportBase
 attr_accessor :headers, :contents, :money_request_processors

 has_scope :filter_completed_date, using: [:from, :to], type: :hash

 def pre_validate

 end

 def init
   self.money_request_processors = user.company.money_request_processors.where(payment_type: %w(bank_transfer payment_file)).includes(mappings: [money_requests: [{user: :profile},items:[:amount]]])
   money_request_processors = apply_scopes(self.money_request_processors, params)



   self.headers = [
       'Account',
       'Sub Account',
       'Department',
       'Cost center',
       'TAX',
       'Base Amount',
       'Debit',
       'Credit',
       'Comments',
       'Supplier',
       'Reference Code',
       'SAC',
       'Ref. Invoice No.'
   ]
   self.contents = []
   count = 1
   money_request_processors .each do |rpg|
         rpg.mappings.each do |rpg_mapping|
           rpg_mapping.money_requests.each do |money_request|
             money_request.items.map do |item|
               next if item.amount.value == 0.0
               self.contents << [
                   item.category&.gl_code,
                   '',
                   money_request.user.gl_config&.dig(:location_code),
                   money_request.user.gl_config&.dig(:cost_center),
                   '',
                   '',
                   item.amount.value,
                   '',
                   '',
                   '',
                   "Money Request ID #{money_request.id}",
                   '',
                   '',
               ]
             end
             self.contents << [
                 '',
                 money_request.user&.profile&.employee_id,
                 money_request.user.gl_config&.dig(:location_code),
                 money_request.user.gl_config&.dig(:cost_center),
                 '',
                 money_request.total_amount,
                 '',
                 '',
                 '',
                 '',
                 "Against settlement of Money Request ID #{money_request.id}",
                 '',
                 ''
             ]
           end
         end
       end
 end

 def success
   Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
 end

end