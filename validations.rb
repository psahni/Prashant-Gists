#DYNAMIC FINDERS AND VALIDATIONS IMPLEMENTATION IN RUBY WITH HASH AS A STORAGE MECHANISM -> Basic Implementations
require 'my_object_store'

class User
  include MyObjectStore
  attr_accessor :name, :age, :gender, :email, :city
  attr_reader :user_id	
  @@counter = 1
	
  #Validations
  validates :name,  :presence => true, :uniqueness => true
  validates :age  ,   :numericality => true,   :min => 18, :max => 50
  validates :city, :presence => true
  validates :email,  :presence => true, :uniqueness => true, :format => /^[a-zA-Z0-9_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/

  
  def initialize(params = {})
     params.keys.each do |key|
     instance_variable_set("@" << key.to_s,params[key])
    end
  end
  
  def save
    #puts "--> Saving user #{ self.inspect }"
    instance_variable_set("@" << :user_id.to_s, @@counter)
    @@counter+=1
    saved = self.class.store(self)
     if saved
       puts "#{self.inspect }\n--> user has been saved successfully.\n\n"
     else
       instance_variable_set("@" << :user_id.to_s, nil)
       puts "--> Following errors have prohibited from this user being saved\n#{self.inspect } \n"
       self.errors.each{|err| p err}
       print "\n"
     end
 end

end

u1 = User.new(:name => "Prashant", :age =>  25, :gender => "male", :email => 'prashant@vinsol.com', :city => 'Agra')
u1.save


u2 = User.new(:name => "Ankur", :age => 25, :gender => 'male', :email => 'ankurs2000@yahoo.com', :city => 'Agra')
u2.save


u3 = User.new(:name => "Alok", :age => 25, :gender => "male", :email => 'prash@vinsol.com', :city => 'Bareilly')
u3.save

u4 = User.new(:name => "Ashima", :age => 23, :gender => 'female', :email => 'ashima@gmail.com', :city => 'Noida')
u4.save

#~ #This user will not be saved
u5 = User.new(:name => "Alok", :age =>  23, :gender => "male", :email => '', :city => 'Bareilly')
u5.save

# Email format error
u6 = User.new(:name => "Amit", :age =>  25, :gender => "male", :email => 'fhdfhkdhf', :city => 'Agra')
u6.save





#p User.current_storage[:email]["prashant@vinsol.com"]
#User.find_by_user_id(1)
#p User.find_by_gender('male')
#p User.find_all_by_age(23)
#p User.find_all
#p User.find_by_email("prashant@vinsol.com")
#p User.find_all_by_city("Agra")