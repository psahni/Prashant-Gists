#DYNAMIC FINDERS AND VALIDATIONS IMPLEMENTATION IN RUBY WITH HASH AS A STORAGE MECHANISM

require 'my_object_store'

class User
	include MyObjectStore
	
 attr_accessor :name, :age, :gender
	attr_reader :user_id
	
	@@counter = 1
	

	def initialize(params = {})
  params.keys.each do |key|
		 instance_variable_set("@" << key.to_s,params[key])
		end
	end
	
	
	def save
		#puts "--> Saving user #{ self.inspect }"
		instance_variable_set("@" << :user_id.to_s, @@counter)
		@@counter+=1
		self.class.store(self)
		#puts "--> user has been saved successfully.\n\n"
	end

end

u1 = User.new(:name => "Prashant", :age =>  25, :gender => "male")
u1.save
u2 = User.new(:name => "Ankur", :age =>  24, :gender => "male")
u2.save
u3 = User.new(:name => "Ravi", :age => 25, :gender => "male")
u3.save

#p User.current_storage[:gender]
p User.find_by_user_id(3) 