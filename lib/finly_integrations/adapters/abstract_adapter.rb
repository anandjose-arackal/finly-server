require_relative '../finly_integrations'
module FinlyIntegrations
  module Adapters
    class AbstractAdapter
      ADAPTER_NAME = :abstract
      
      def setup_connection(auth_obj)
        raise "Method #{__callee__} of #{self.class} not implemented."
      end

      def categories(updated_at = nil)
        raise "Method #{__callee__} of #{self.class} not implemented."
      end

      def employees(updated_at = nil)
        raise "Method #{__callee__} of #{self.class} not implemented."
      end

      def tags(updated_at = nil)
        raise "Method #{__callee__} of #{self.class} not implemented."
      end

      def save_report(report)
        raise "Method #{__callee__} of #{self.class} not implemented."
      end
    end
  end
end