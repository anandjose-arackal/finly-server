class Personalizer::Adapters::Company2::ExportTemplates2::Tally < Personalizer::Adapters::ExportBase

  def pre_validate

  end

  def success
    Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter.new(user, {}, messages)
  end

  class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter

    def render(controller)
      controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
    end

  end

end