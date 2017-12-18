class Statements::Team::Export < Statements::Team::Base
  attr_accessor :result

  def process
    self.result = Statements::Team::Summary.(user, params)
    unless self.result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {template: 'statements/user_summary_export', headers: [self.result.generate_header_group, self.result.generate_header_main], contents: self.result.generate_contents}, messages)
  end

end