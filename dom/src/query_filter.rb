# The Query Filter stores options that can be used to modify a query to an XML document.
class QueryFilter 
    def initialize(options)
        @options = options
    end

    attr_reader :options
end