class ExportTemplates::BaseGenerator
  include Supporters::ErrorTracker

  attr_accessor :user, :template, :configuration

  def initialize(user, template)
    self.user = user
    self.template = template
    self.configuration = template&.configuration
  end

  def process(data)
    raise 'Cannot process export template as it is in base class'
  end

  def save_to_file_manager(file)
    self.user.file_managers.create export_template: self.export_template, file: file
  end

  def save_to_temp_file(filename, data)
    file_path = "#{temp_file_path}/#{filename}"
    File.open(file_path, "w+") do |f|
      f.write data
    end
  end

  def temp_file_path
    path = "#{Rails.root}/tmp/files/#{self.user.id}/#{object_id}"
    FileUtils.mkdir_p(path) unless File.directory?(path)
    path
  end

  class ExportTemplates::BaseGenerator::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :output



  end

end