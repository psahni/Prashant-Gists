#SCRIPT TO CREATE CLASSES AND METHODS DYNAMICALLLY ON THE BASIS OF CSV FILE 

def check_usage
	unless ARGV.length ==1 
		puts "Usage: You must input some file in csv format."
		exit
	end
end
#---------------------------------------------------------------------------------

def read_filename
	@filename = ARGV[0]
	@klass = File.basename(@filename, '.csv')
	@klass.capitalize!
	@klass = @klass.intern
end

#---------------------------------------------------------------------------------	
def make_class
	puts "The class name is " << @klass.to_s
	Object::const_set(@klass, Class::new {
	def self.start_process(file_to_read)
		 fobject         = File.readlines(file_to_read)
		 properties = fobject.first.chomp.split(",") #THE FIRST LINE MUST CONTAIN PROPERTIES OF THE OBJECT THAT WE HAVE TO MAKE
		 self.class_eval do
		 	define_method "initialize" do |*args|
				args  = args[0].split(",")
				 unless properties.length == args.length
					puts "\nInvalid Arguments, #{ properties.length } required, you supplied #{ args.length } !!\n"
					exit
				 end
				 args.each_with_index do |arg, i|
					 instance_variable_set("@"+ properties[i].strip, arg)
				 end		 
			end
		end		
		properties.each do |property|
			class_eval do
				define_method "#{ property.intern }" do
					instance_variable_get("@"+ property.strip)
				 end
			 end
		 end
	end
		 
	}
)
end

#---------------------------------------------------------------------------------

def current_class
	Object::const_get(@klass)
end
#---------------------------------------------------------------------------------

def make_methods
	current_class.start_process(@filename)
end
#---------------------------------------------------------------------------------

def retrive_data
	fobject         = File.readlines(@filename)
	@collection     = Array.new
	methods_available = current_class.instance_methods(false)
	puts "Methods:"
	puts "-"*80
	methods_available.each  do |m|
		print m, " "
	end
	print "\n"
	puts "-"*80
	for i in 1..fobject.length-1
		str = fobject[i].chop
		obj = current_class.new(str)
		@collection << obj
	end
	puts "Here is the collection"
	
	@collection.each_with_index do |collection, i|
		print "-"*80, "\n\n"
		p "collection[#{i}]"
		p collection
		
		methods_available.each do |method|
			print "collection[#{i}].#{method.to_s.strip} =  #{ collection.send(method) } \n"
		end
		print "\n"
	end
	print "-"*80, "\n"
end
#---------------------------------------------------------------------------------
check_usage
read_filename
make_class
make_methods
retrive_data

