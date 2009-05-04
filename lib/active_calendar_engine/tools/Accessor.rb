module Accessor
  def attr_accessors(*names)
    names.each do |name|
      attr_name = "@#{name}"
      
      define_method(name) do
        instance_variable_get(attr_name)
      end
      
      define_method("#{name}=") do |value|
        instance_variable_set(attr_name, value)
      end
      
    end
  end
end