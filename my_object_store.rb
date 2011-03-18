module MyObjectStore
  def self.included(base)	
    base.extend(ClassMethods)
    base.instance_eval %{
      @@object_attrs = []
      
      def attr_accessor(*args)		
        super	
	self.object_attributes=(args)
      end
      
      def attr_reader(*args)
       super
       self.object_attributes=(args)
      end
      
      def object_attributes=(*args)
	@@object_attrs << args
      end
     
      def object_attributes
	@@object_attrs.flatten
      end
    }
  end
  
  module ClassMethods
    @@storage_hash = {}
  
    def store(obj)
     @obj_store = prepare_storage_criteria
      instance_methods.each do |method|
       @obj_store[method][obj.send(method).to_s] ||= Array.new
       @obj_store[method][obj.send(method).to_s] << obj
      end
     @obj_store
    end
#----------------------------------------------------------------------------------------------------------
# THERE WILL BE HASHES CONTAINING HASHES WITH KEY AS ATTRIBUTE NAMES THAT CONTAIN OBJECT INSTANCES
#----------------------------------------------------------------------------------------------------------

    def prepare_storage_criteria
      return @@storage_hash if @@storage_hash.keys.length == instance_methods.length
      instance_methods.each do |attr|
       @@storage_hash[attr] = {}
     end
     @@storage_hash
    end
    
    def current_storage
      @@storage_hash
    end
    
    def retrive_data(key, args)
      @@storage_hash[key.to_sym][args.to_s].first
    end
    
#-------------------------------------------------------------------------------

    def method_missing(method_id, *args )
     attribute_names = instance_methods
     @current_attr = extract_attribute_name(method_id)
     
     raise "The attribute #{ @current_attr } is not valid. Valid attributes are #{ attribute_names.join(',') }" unless attribute_names.include?(@current_attr.to_sym)
      self.class_eval %{
       def self.#{method_id}(*args)
        retrive_data(@current_attr, args)
       end
     }
     send(method_id, *args)
    end
    
#-------------------------------------------------------------------------------

   def instance_methods
     self.object_attributes
   end
   
#-------------------------------------------------------------------------------

   def extract_attribute_name(method)
     method.to_s.match(/^find_by_([a-z]\w*)$/)
     name = $1
   end
   
#-------------------------------------------------------------------------------

    #~ def attributes
      #~ instance_methods.inject([]){|@attr_array, method| @attr_array << method.to_s.gsub("=", "") }
      #~ @attr_array.uniq
    #~ end

#-------------------------------------------------------------------------------

  end#End Of ClassMethods
  
end