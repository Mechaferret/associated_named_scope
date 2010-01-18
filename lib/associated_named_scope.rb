module ActiveRecord
  module NamedScope
    module AssociatedNamedScope
      class UndefinedAssociationOption < ActiveRecordError # :nodoc:
        def initialize(klass, option)
          super("Undefined #{option} for associated named scope in #{klass}")
        end 
      end

      def self.included(base)
        unless ActiveRecord::NamedScope::Scope.instance_methods.include?("rewrite_associated_scope") # only include once          
          ActiveRecord::NamedScope::Scope.send(:include, ActiveRecord::NamedScope::AssociatedScopeRewrite)
        end
      end
    end
      
    module AssociatedScopeRewrite
      def self.included(base)
        base.class_eval do
          alias_method_chain :initialize, :association
          alias_method_chain :method_missing, :association
        end
      end
      
      def initialize_with_association(proxy_scope, options, &block)
        initialize_without_association(proxy_scope, options, &block)
        @proxy_options = rewrite_associated_scope(@proxy_options)
      end
      
      def method_missing_with_association(method, *args, &block)
        if scopes.include?(method)
          method_missing_without_association(method, *args, &block)
        else
          if @association_proxy_options && @association_include_options
             with_scope({:find => @association_proxy_options, :create => @association_proxy_options[:conditions].is_a?(Hash) ?  @association_proxy_options[:conditions] : {}}, :reverse_merge) do
              with_scope({:find => @association_include_options, :create => {}}, :reverse_merge) do
                method_missing_without_association(method, *args, &block)
              end
            end
          else
            method_missing_without_association(method, *args, &block)
          end
        end
      end
      
      def rewrite_associated_scope(options)
        if options[:association]
          raise ActiveRecord::NamedScope::AssociatedNamedScope::UndefinedAssociationOption.new(@proxy_scope,:scope) unless (scope=options[:association][:scope])
          raise ActiveRecord::NamedScope::AssociatedNamedScope::UndefinedAssociationOption.new(@proxy_scope,:source) unless (source=options[:association][:source])
          source_reflection = reflect_on_nested_association(@proxy_scope, source) 
          @association_proxy_options = source_reflection.klass.send(*scope).proxy_options
          @association_include_options= {:include=>source}
          return options.except(:association)
        else
          return options
        end
      end
      
      def reflect_on_nested_association(klass, source)
        if source.instance_of? Hash
          top_association = source.keys.first
          next_reflection = klass.reflect_on_association(top_association)
          reflect_on_nested_association(next_reflection.klass, source[top_association])
        else
          klass.reflect_on_association(source)
        end
      end

    end

  end
end
