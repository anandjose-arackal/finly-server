module Sequenced
  class Generator
    attr_reader :record, :scope, :column, :start_at, :skip

    def initialize(record, options = {})
      unless record.has_attribute?('company_id')
        raise "Sequenced: #{record.class.name} does not have #{company_id} defined"
      end
      unless Purpose.id_for(options[:purpose]).present?
        raise "Sequenced: #{record.class.name} purpose does not exist"
      end
      @record = record
      @scope = options[:scope]
      @column = options[:column].to_sym
      @start_at = options[:start_at]
      @skip = options[:skip]
      @prefix = options[:prefix] || ''
      @sequenced_editable = options[:editable]
      @config = UniqueIdentifier.with_company_id(record.company_id).with_purpose_id(Purpose.id_for(options[:purpose]))&.first
      @start_at ||= @config&.sequence_start
      @min_sequence_length = @config&.sequence_start&.length || 5
      process_prefix
    end

    def set
      return if id_set? || skip?
      return if @sequenced_editable and record.send(:"#{column}").present?
      # record.with_lock do
        record.send(:"#{column}=", next_id)
      # end
    end

    def id_set?
      !record.send(column).nil?
    end

    def skip?
      skip && skip.call(record)
    end

    def next_id
      seq = next_id_in_sequence
      seq += 1 until unique?(format_id(seq))
      format_id(seq)
    end

    def format_id(id)
      "#{@prefix}#{id.to_s.rjust(@min_sequence_length, '0')}"
    end

    def next_id_in_sequence
      start_at = self.start_at.respond_to?(:call) ? self.start_at.call(record) : self.start_at
      return start_at unless (last_record = find_last_record)
      last_sequence_value = last_record.send(column).scan(Constants::ENDING_NUMBERS).first&.to_i || 0
      max(last_sequence_value + 1, start_at)
    end

    def unique?(id)
      return false unless id.present?
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where("NOT id = ?", record.id) if record.persisted?
        rel.where(column => id)
      end.count == 0
    end

    private
    def base_relation
      record.class.base_class.unscoped.where(company_id: record.company_id)
    end

    def process_prefix
      @prefix = @config&.prefix || @prefix
      @prefix = ExpressionEvaluator::Transformer.(@prefix) unless @prefix.blank?
    end

    def find_last_record
      build_scope(*scope) do
        base_relation.
            where("#{column.to_s} IS NOT NULL AND #{column.to_s} LIKE '#{@prefix}%'").
            order("created_at DESC")
      end.first
    end

    def build_scope(*columns)
      rel = yield
      columns.each {|c| rel = rel.where(c => record.send(c.to_sym))}
      rel
    end

    def max(*values)
      values.to_a.max
    end

  end
end