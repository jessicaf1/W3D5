
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    #debugger
      names.each do |name|
        #debugger
          define_method(name) do  
             instance_variable_get("@#{name}") 
          end  
           define_method("#{name}=") do |value| 
            instance_variable_set("@#{name}", value)
          end  
      end
  end 



end
