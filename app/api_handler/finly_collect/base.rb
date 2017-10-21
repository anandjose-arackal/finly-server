class FinlyCollect::Base < BaseHandler

  CONFIG = YAML.load_file "#{Rails.root}/config/finly_collect.yml"

  def env_key
    'finly_collect'
  end

  def header_params
    {
        'Authorization': "Basic #{CONFIG['auth']}"
    }
  end

  def parse
    self.parsed_response = JSON.parse(self.response&.body).with_indifferent_access rescue nil
    unless self.parsed_response&.dig(:success)
      message = self.parsed_response&.dig(:message, :error)
      if message.blank?
        message = 'Unknown error'
      end
      add_message :error, message
    end
  end

  def success?
    super and self.parsed_response[:success]
  end

end