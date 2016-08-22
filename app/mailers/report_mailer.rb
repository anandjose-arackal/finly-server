class ReportMailer < ApplicationMailer

  HANDLERS = [:submit, :approve, :retract, :reject]

  HANDLERS.each do |handle|
    define_method handle do |presenter|
      return unless presenter.validate
      @data = presenter
      mail to: presenter.to, subject: presenter.subject, template_name: 'template'
    end
  end

end
