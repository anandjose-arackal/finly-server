class Personalizer::Adapters::Company164::ExportTemplates164::SettledMoneyRequestTemplate < Personalizer::Adapters::ExportBase
 attr_accessor :headers, :contents, :money_request_processors

 has_scope :filter_completed_date, using: [:from, :to], type: :hash

 def pre_validate

 end

 def init
   self.money_request_processors = user.company.money_request_processors.includes(mappings: [money_requests: [{user: :profile},items:[:amount]]])
   money_request_processors = apply_scopes(self.money_request_processors, params)



   self.headers = [
       'Account',
       'Sub Account',
       'Department',
       'Cost Center',
       'Tax',
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
   
   money_request_processors .each do |rpg|
         rpg.mappings.each do |rpg_mapping|
           rpg_mapping.money_requests.each do |money_request|
               self.contents << [
                   31352001,
                   '',
                   "'#{money_request.user.gl_config&.dig(:location_code)}",
                   money_request.user.gl_config&.dig(:cost_center),
                   '',
                   '',
                   money_request.total_amount,
                   '',
                   '',
                   money_request.user&.profile&.employee_id,
                   "Against Money Request No. #{money_request.id}",
                   '',
                   '',
               ]
             self.contents << [
                 '61110004',
                 '9992',
                 "'#{money_request.user.gl_config&.dig(:location_code)}",
                 money_request.user.gl_config&.dig(:cost_center),
                 '',
                 '',
                 '',
                 money_request.total_amount,
                 '',
                 '',
                 '',
                 '',
                 ''
             ]
           end

         end
       end
 end

end