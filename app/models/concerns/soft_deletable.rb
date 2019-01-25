module SoftDeletable
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid

    default_scope {where(deleted_at: nil)}
    scope :only_deleted, -> {include_soft_deleted.where.not(deleted_at: nil)}
    scope :exclude_deleted, -> {where(deleted_at: nil)}
    scope :include_soft_deleted, -> {unscope(where: :deleted_at)}
    scope :non_deleted, -> {where deleted_at: nil}

  end

  module ClassMethods
    # Migration for transitioning to new paranoid
    def migrate_to_paranoid
      unless has_attribute? :deleted_at
        ActiveRecord::Migration.add_column self.table_name, :deleted_at, :datetime, index: true
      end
      if has_attribute? :is_deleted
        self.unscoped.where(is_deleted: true).update_all(deleted_at: DateTime.now)
      end
    end
  end

  # included do
  #   default_scope { where(is_deleted: [false, nil]) }
  #   scope :only_deleted, -> { where(is_deleted: true) }
  #   scope :exclude_deleted, -> { where(is_deleted: [false, nil]) }
  #   scope :include_soft_deleted, -> { unscope(where: :is_deleted) }
  #   scope :non_deleted, -> {where is_deleted: [nil, false]}
  # end
  #
  # def delete
  #   update_column :is_deleted, true if has_attribute? :is_deleted
  # end
  #
  # def destroy;
  #   callbacks_result = transaction do
  #     run_callbacks(:destroy) do
  #       delete
  #     end
  #   end
  #   callbacks_result ? self : false
  # end
  #
  # def self.included(klazz)
  #   klazz.extend Callbacks
  # end
  #
  # module Callbacks
  #   def self.extended(klazz)
  #     klazz.define_callbacks :restore
  #     klazz.define_singleton_method("before_restore") do |*args, &block|
  #       set_callback(:restore, :before, *args, &block)
  #     end
  #     klazz.define_singleton_method("around_restore") do |*args, &block|
  #       set_callback(:restore, :around, *args, &block)
  #     end
  #     klazz.define_singleton_method("after_restore") do |*args, &block|
  #       set_callback(:restore, :after, *args, &block)
  #     end
  #   end
  # end
  #
  # def restore!(opts = {})
  #   self.class.transaction do
  #     run_callbacks(:restore) do
  #       update_column :is_deleted, false
  #       restore_associated_records if opts[:recursive]
  #     end
  #   end
  #   self
  # end
  #
  # alias :restore :restore!
  #
  # def restore_associated_records
  #   destroyed_associations = self.class.reflect_on_all_associations.select do |association|
  #     association.options[:dependent] == :destroy
  #   end
  #   destroyed_associations.each do |association|
  #     association_data = send(association.name)
  #     unless association_data.nil?
  #       if association_data.is_deleted?
  #         if association.collection?
  #           association_data.only_deleted.each { |record| record.restore(recursive: true) }
  #         else
  #           association_data.restore(recursive: true)
  #         end
  #       end
  #     end
  #     if association_data.nil? && association.macro.to_s == 'has_one'
  #       association_class_name = association.options[:class_name].present? ? association.options[:class_name] : association.name.to_s.camelize
  #       association_foreign_key = association.options[:foreign_key].present? ? association.options[:foreign_key] : "#{self.class.name.to_s.underscore}_id"
  #       Object.const_get(association_class_name).only_deleted.where(association_foreign_key, self.id).first.try(:restore, recursive: true)
  #     end
  #   end
  #   clear_association_cache if destroyed_associations.present?
  # end
end
