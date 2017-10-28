class Personalizer::Adapters::Company2::ExportTemplates2::Tally < Personalizer::Adapters::ExportBase
  attr_accessor :expenses

  has_scope :filter_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def process
    users_presenter = User::Index.(user, params)
    unless users_presenter&.success?
      add_message :error, users_presenter.messages[:error]
      return
    end
    users = users_presenter.team
    user_ids = users.pluck(:id)
    reports = apply_scopes Report.with_user_id(user_ids).processed
    report_ids = reports.pluck(:id)
    self.expenses = Expense.with_report_id(report_ids)
  end

  def success
    current_class_path = self.method(:success).source_location.first.gsub('/tally.rb', '')
    template = "#{current_class_path}/tally.xml"
    Exporter.new(user, {xml: {template: template, local_variables: {expenses: expenses}}}, messages)
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end