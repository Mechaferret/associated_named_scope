module ActiveRecord
  class UndefinedScopeAssociationSource < ActiveRecordError # :nodoc:
    def initialize(reflection, scope)
      super("Source not specified for association in scope '#{scope}' for #{reflection.to_s}.")
    end 
  end

  class UndefinedScopeAssociationScope < ActiveRecordError # :nodoc:
    def initialize(reflection, scope)
      super("Associated scope not specified for association in scope '#{scope}' for #{reflection.to_s}.")
    end 
  end

  module NamedScope
    module AssociatedNamedScope
			def self.included(base)
				base.extend ClassMethods
			end
			
			module ClassMethods
			  def has_associated_named_scopes
					extend ActiveRecord::NamedScope::AssociatedNamedScope::SingletonMethods
					class << self
						alias_method_chain :named_scope, :associations
					end
				end
      end
      
      module SingletonMethods
				def named_scope_with_associations(name, options = {}, &block)
          name = name.to_sym
          scopes[name] = lambda do |parent_scope, *args|
            ScopeWithAssociations.new(parent_scope, case options
              when Hash
                options
              when Proc
                options.call(*args)
            end, &block)
          end
          (class << self; self end).instance_eval do
            define_method name do |*args|
              scopes[name].call(self, *args)
            end
          end
				end      
      end
      
      class ScopeWithAssociations < ActiveRecord::NamedScope::Scope
        def initialize(proxy_scope, options, &block)
          options ||= {}
          [options[:extend]].flatten.each { |extension| extend extension } if options[:extend]
          extend Module.new(&block) if block_given?
          unless Scope === proxy_scope
            @current_scoped_methods_when_defined = proxy_scope.send(:current_scoped_methods)
          end
          @proxy_scope, @proxy_options = proxy_scope, self.rewrite_association_options(options.except(:extend))
          puts "proxy scope is #{@proxy_scope.inspect}, proxy options are #{@proxy_options.inspect}"
        end
      
        def rewrite_association_options(options)
					if options[:association]
					  raise UndefinedScopeAssociationScope(self, name) unless (scope = options[:association][:scope])
					  raise UndefinedScopeAssociationSource(self, name) unless (source = options[:association][:source])
						source_class = Address # uh, get this out of source using reflection somehow
						source_joins = "INNER JOIN users ON tutors.user_id = users.id LEFT JOIN addresses ON addresses.addressable_id = users.id AND addresses.addressable_type = 'User'" #same
						association_proxy_options = source_class.send(*scope).proxy_options
						puts "proxy options are #{association_proxy_options.inspect}"
						options.delete(:association)
						puts "starting with #{options.inspect}"
						final_options = options.merge(association_proxy_options).merge(:joins=>source_joins)
						puts "final options are #{final_options.inspect}"
						return final_options
					else
						return options
					end
        end
      end
    end
  end
end
