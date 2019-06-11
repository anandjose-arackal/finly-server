class PaymentProcessorRules::Checker < RuleBook::Chapter

  class PaymentProcessorRules::Checker::Verdict < RuleBook::Verdict

    define_property :instance, :response_code, :messages

    def add_system_message(type, model, message)
      return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
      message = [message] unless message.is_a?(Array)
      system_message_type = SystemMessageType.id_for(type)
      message.each do |m|
        SystemMessage.create(messagable: model, content: m, system_message_type_id: system_message_type)
      end
    end
  end

  act PaymentProcessorRules::Registry
  verdict PaymentProcessorRules::Checker::Verdict

end