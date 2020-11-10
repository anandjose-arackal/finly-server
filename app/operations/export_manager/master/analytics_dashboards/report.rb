class ExportManager::Master::AnalyticsDashboards::Report < ExportManager::API

  handle :analytics_dashboard_export

  def input
    nil
  end

  def load_data
    CubeJs::Load.(params: params.to_unsafe_h.with_indifferent_access, current_user: user) do |m|
      m.success do |result|
        return result
      end

      m.failure do |result|
        return nil
      end

      m.wait do |result|
        attempt += 1
        if attempt > 3
          return nil
        else
          # Sleep for 15 seconds and check again
          sleep 15
        end
      end
    end
  end

  def generate
    data = load_data&.dig('data') || []
    failure! and return if data.blank?

    # Update total records
    self.export_job.total_records = data.count
    self.export_job.save

    file = generate_spreadsheet(data)
    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  def generate_spreadsheet(data)
    header = []
    data.first&.each_pair do |key, value|
      header << key
    end

    return unless data.present?

    file = Paperclip::Tempfile.new(file_name)
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)
    worksheet = workbook.add_worksheet('Sheet 1')
    data.each_with_index do |row, index|
      row.each do |column, value|
        worksheet.write(index + 1, header.find_index(column), value)
      end

      progress_update(index + 1)
    end
    header.each_with_index do |item, index|
      worksheet.write(0, index, item)
    end
    workbook.close

    file.rewind
    file
  end

  def file_name
    case format
    when :csv
      ['export', '.csv']
    when :xls
      ['export', '.xls']
    end
  end

  def format
    params[:export_format]&.to_sym || :xls
  end

end