module OverrideMethods

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # a class method that creates methods that need to be overridden
    # in the abstract base class.
    #
    #   override_methods :size, :clear, [:record, "rec"], :find_by
    #
    def override_methods(*method_names)
      method_names.each do |method_name_or_signature|
        if method_name_or_signature.kind_of? Array
          method_name = method_name_or_signature.shift
          method_args = method_name_or_signature
        else
          method_name = method_name_or_signature
          method_args = []
        end
        
        define_method(method_name) do |*method_args|
          raise MethodNotOverridden.new(method_name)
        end
      end
    end
  end

  class MethodNotOverridden < Exception
    def initialize(method_name)
      super("Method '#{method_name}' needs to be overridden")
    end
  end

end
