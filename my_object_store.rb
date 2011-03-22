module MyObjectStore
  def self.included(base)	
	  
    base.extend(ClassMethods)
    base.extend(Validations)
    
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
     perform_validations(obj)
     return false if obj.errors.any?
     @obj_store = prepare_storage_criteria
      instance_methods.each do |method|
       @obj_store[method][obj.send(method).to_s] ||= Array.new
       @obj_store[method][obj.send(method).to_s] << obj
      end
     true
    end
    
   
    
    def find_all
     @arr = []
     current_storage[:user_id].each_key do |k|
	@arr << current_storage[:user_id][k]
     end
    @arr.flatten
    end
    
   alias :all  :find_all
    
#----------------------------------------------------------------------------------------------------------
# THERE WILL BE HASHES CONTAINING HASHES WITH KEY AS ATTRIBUTE NAMES THAT CONTAIN ARRAY OF OBJECT INSTANCES
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
    
    def retrive_data_by_attribute(key, args)
      if !self.current_storage.empty? && self.current_storage.has_key?(key)
	return current_storage[key][args[0]].first if current_storage[key][args[0]]
      end
    end
    
    def retrive_all_data_by_attribute(key, args)
	if !self.current_storage.empty? && self.current_storage.has_key?(key)
		current_storage[key][args[0].to_s]
	  else
	    []
	end
    end
    
#-------------------------------------------------------------------------------

    def method_missing(method_id, *args )
     attribute_names = instance_methods
     @current_attr, @seprator = extract_attribute_name(method_id)
     raise "The attribute #{ @current_attr } is not valid. Valid attributes are #{ attribute_names.join(',') }" unless attribute_names.include?(@current_attr.to_sym)
      self.class_eval %{
       def self.#{method_id}(*args)
         @seprator == 'all_by' ? retrive_all_data_by_attribute(@current_attr.to_sym, args)  : retrive_data_by_attribute(@current_attr.to_sym, args)      
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
     method.to_s.match(/^find_(all_by|by)_([a-z]\w*)$/)
     [$2, $1]
   end
   
#-------------------------------------------------------------------------------

    #~ def attributes
      #~ instance_methods.inject([]){|@attr_array, method| @attr_array << method.to_s.gsub("=", "") }
      #~ @attr_array.uniq
    #~ end

#-------------------------------------------------------------------------------

  end#End Of ClassMethods
  
  module Validations
  
   def validates(attr, options = {})
    @options = options
    @attr = attr
   end
   
   def  perform_validations(obj)
    "Inside validations"
    obj.instance_eval {
	@errors = []
	
	def errors
	  @errors
        end
         
	def add_errors(error)
	 @errors << error
	end
  
    }
   
   if @options.has_key?(:presence) && obj.send(@attr).to_s.length == 0
    obj.add_errors("#{@attr.to_s.capitalize} can't be blank") 
   end
   
   if @options.has_key?(:uniqueness)
    u = obj.class.send("find_by_#{ @attr }", obj.name)
    obj.add_errors("#{@attr.to_s.capitalize} has already been taken") if u 
   end
    
   end
   
  end#Validations
end
