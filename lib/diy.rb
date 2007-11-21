require 'yaml'
require 'set'

module DIY
  VERSION = '1.0.0'
	class Context
		def initialize(context_hash, extra_inputs={})
			raise "Nil context hash" unless context_hash
			raise "Need a hash" unless context_hash.kind_of?(Hash)
			[ "[]", "keys" ].each do |mname|
				unless extra_inputs.respond_to?(mname) 
					raise "Extra inputs must respond to hash-like [] operator and methods #keys and #each" 
				end
			end

			# store extra inputs
			if extra_inputs.kind_of?(Hash)
				@extra_inputs = {}
				extra_inputs.each { |k,v| @extra_inputs[k.to_s] = v } # smooth out the names
			else
				@extra_inputs = extra_inputs
			end

			# Collect object and subcontext definitions
			@defs = {}
			@sub_context_defs = {}
			context_hash.each do |name,info|
				name = name.to_s
				case name
				when /^\+/ 
					# subcontext
					@sub_context_defs[name.gsub(/^\+/,'')] = info
					
				else 
          # Normal singleton object def
          if extra_inputs_has(name)
            raise ConstructionError.new(name, "Object definition conflicts with parent context")
          end
          @defs[name] = ObjectDef.new(:name => name, :info => info)
				end
			end


			# init the cache
			@cache = {}
			@cache['this_context'] = self
		end
   

		def self.from_yaml(io_or_string, extra_inputs={})
			raise "nil input to YAML" unless io_or_string
			Context.new(YAML.load(io_or_string), extra_inputs)
		end

		def self.from_file(fname, extra_inputs={})
			raise "nil file name" unless fname
			self.from_yaml(File.read(fname), extra_inputs)
		end

		def get_object(obj_name)
			key = obj_name.to_s
			obj = @cache[key]
			unless obj
				if extra_inputs_has(key)
					obj = @extra_inputs[key]
				end
			end
			unless obj
				obj = construct_object(key)
				@cache[key] = obj if @defs[key].singleton?
			end
			obj
		end
		alias :[] :get_object

		def set_object(obj_name,obj)
			key = obj_name.to_s
			raise "object '#{key}' already exists in context" if @cache.keys.include?(key)
			@cache[key] = obj
		end
		alias :[]= :set_object

		def keys
			(@defs.keys.to_set + @extra_inputs.keys.to_set).to_a
		end

		# Instantiate and yield the named subcontext
		def within(sub_context_name)
			# Find the subcontext definitaion:
			context_def = @sub_context_defs[sub_context_name.to_s]
			raise "No sub-context named #{sub_context_name}" unless context_def
			# Instantiate a new context using self as parent:
			context = Context.new( context_def, self )

			yield context
		end

		def contains_object(obj_name)
			key = obj_name.to_s
			@defs.keys.member?(key) or extra_inputs_has(key)
		end

		def build_everything
			@defs.keys.each { |k| self[k] }
		end
		alias :build_all :build_everything
		alias :preinstantiate_singletons :build_everything

		private

		def construct_object(key)
			# Find the object definition
			obj_def = @defs[key]
			raise "No object definition for '#{key}'" unless obj_def

			# If object def mentions a library, load it
			require obj_def.library if obj_def.library

			# Resolve all components for the object
			arg_hash = {}
			obj_def.components.each do |name,value|
				case value
				when Lookup
					arg_hash[name.to_sym] = get_object(value.name)
				when StringValue
					arg_hash[name.to_sym] = value.literal_value
				else
					raise "Cannot cope with component definition '#{value.inspect}'"
				end
			end
			# Get a reference to the class for the object
			big_c = get_class_for_name_with_module_delimeters(obj_def.class_name)
			# Make and return the instance
			if arg_hash.keys.size > 0
  			return big_c.new(arg_hash)
			else
				return big_c.new
			end
		rescue Exception => oops
			cerr = ConstructionError.new(key,oops)
			cerr.set_backtrace(oops.backtrace)
			raise cerr
		end

		def get_class_for_name_with_module_delimeters(class_name)
			class_name.split(/::/).inject(Object) do |mod,const_name| mod.const_get(const_name) end
		end

		def extra_inputs_has(key)
			if key.nil? or key.strip == ''
				raise ArgumentError.new("Cannot lookup objects with nil keys")
			end
			@extra_inputs.keys.member?(key) or @extra_inputs.keys.member?(key.to_sym)
		end
	end

	class Lookup #:nodoc:
		attr_reader :name
		def initialize(obj_name)
			@name = obj_name
		end
	end

	class ObjectDef #:nodoc:
		attr_accessor :name, :class_name, :library, :components
		def initialize(opts)
      name = opts[:name]
      raise "Can't make an ObjectDef without a name" if name.nil?

      info = opts[:info] || {}
      info = info.clone

			@components = {}

			# Object name
			@name = name

			# Class name
			@class_name = info.delete 'class'
			@class_name ||= info.delete 'type'
			@class_name ||= camelize(@name)

			# Library
			@library = info.delete 'library'
			@library ||= info.delete 'lib'
			@library ||= underscore(@class_name)

			# Auto-compose
			compose = info.delete 'compose'
			if compose
				case compose
				when Array
					auto_names = compose.map { |x| x.to_s }
				when String
					auto_names = compose.split(',').map { |x| x.to_s.strip }
				when Symbol
					auto_names = [ compose.to_s ]
				else
					raise "Cannot auto compose object #{@name}, bad 'compose' format: #{compose.inspect}"
				end
			end
			auto_names ||= []
			auto_names.each do |cname|
				@components[cname] = Lookup.new(cname)
			end

      # Singleton status
      if info['singleton'].nil?
        @singleton = true
      else
        @singleton = info['singleton']
      end
      info.delete 'singleton'

			# Remaining keys
			info.each do |key,val|
				@components[key.to_s] = Lookup.new(val.to_s)
			end

		end

    def singleton?
      @singleton
    end

		private
		# Ganked this from Inflector:
		def camelize(lower_case_and_underscored_word)
			lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
		end
		# Ganked this from Inflector:
		def underscore(camel_cased_word)
			camel_cased_word.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
		end
	end

	# Exception raised when an object can't be created which is defined in the context.
	class ConstructionError < RuntimeError 
		def initialize(object_name, cause=nil) #:nodoc:
			object_name = object_name
			cause = cause
			m = "Failed to construct '#{object_name}'"
			if cause 
				m << "\n  ...caused by:\n  >>> #{cause}"
			end
			super m
		end
	end
end
