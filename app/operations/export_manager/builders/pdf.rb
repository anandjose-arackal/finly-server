class ExportManager::Builders::Pdf < ExportManager::API

  include MathUtil

  attr_accessor :multiple_sheet, :header

  type :pdf

  def self.config
  end

  def generate
    file = generate_pdf
    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  def generate_pdf

  end

  def file_name
      ['export', '.pdf']
  end

  def format
    :pdf
  end

end