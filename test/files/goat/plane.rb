require 'base'
require 'constructor'
class Plane < Base
	constructor :wings, :strict => true
	def setup
		test_output "plane"
	end		
end
