# Use this macro if you want changes in your model to be saved in an audit table.
# The audits table must exist.
#
#   class Booking
#     simple_audit
#   end
#
# See SimpleAudit::ClassMethods#simple_audit for configuration options

module SimpleAudit

  module Model
    def self.included(base) #:nodoc:
      base.send :extend, ClassMethods
    end

    module ClassMethods

      # == Configuration options
      #
      # * <tt>username_method => symbol</tt> - Call this method on the current user to get the name
      #
      # With no block, all the attributes and <tt>belongs_to</tt> associations (id and to_s) of the audited model will be logged.
      #
      #    class Booking
      #      # this is equivalent to passing no block
      #      simple_audit do |audited_record|
      #        audited_record.attributes
      #      end
      #    end
      #
      # If a block is given, the data returned by the block will be saved in the audit's change log.
      #
      #    class Booking
      #      has_many :housing_units
      #      simple_audit do |audited_record|
      #        {
      #          :some_relevant_attribute => audited_record.some_relevant_attribute,
      #          :human_readable_serialization_of_aggregated_models => audited_record.housing_units.collect(&:to_s),
      #          ...
      #        }
      #      end
      #    end
      #

      def simple_audit(options = {}, &block)
        class_eval do

          class_attribute :username_method
          class_attribute :audit_changes
          class_attribute :audit_changes_only

          self.username_method = (options[:username_method] || :name).to_sym
          self.audit_changes_only = options[:audit_changes_only] === true

          attributes_and_associations = proc do |record|
            changes = record.attributes
            record.class.reflect_on_all_associations(:belongs_to).each do |assoc|
              changes[assoc.name] = record.send(assoc.name).to_s
            end
            changes
          end
          audit_changes_proc = block_given? ? block.to_proc : attributes_and_associations
          
          self.audit_changes = audit_changes_proc

          has_many :audits, :as => :auditable, :class_name => '::SimpleAudit::Audit'

          after_create {|record| record.class.audit(record, :create, nil)}
          after_update {|record| record.class.audit(record, :update, nil)}
        end
      end

      def audit(record, action = :update, user = nil) #:nodoc:
        
        # check current user for typical Authentication systems
        user = nil
        if defined?(User) and User.respond_to?(:current)
          user = User.current 
        elsif defined?(Cms::User) and Cms::User.respond_to?(:current)
          user = Cms::User.current 
        end

        current_change_log = self.audit_changes.call(record)

        # do only log if anything changed
        record_changed = true
        if audit_changes_only and last_change_log = record.audits.last
          record_changed = last_change_log.change_log != current_change_log
        end

        if record_changed
          if user.present?
            record.audits.create(:user => user,
              :username => user.try(self.username_method),
              :action => action.to_s,
              :change_log => current_change_log)
          else
            record.audits.create(
              :action => action.to_s,
              :change_log => current_change_log)
          end
        end
      end
    end
    
  end
end
