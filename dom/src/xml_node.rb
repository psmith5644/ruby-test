# An XML Node stores the data for a section of XML - an element, attribute, or text
# They are stored in a tree.
module XmlNode

    def initialize(parent = nil)
        @parent = parent
        @firstChild = nil
        @lastChild = nil
        @nextSibling = nil
        @prevSibling = nil
        @filename = nil
        @startLocation = nil
        @endLocation = nil
    end

    attr_accessor :firstChild
    attr_accessor :lastChild
    attr_accessor :parent
    attr_accessor :nextSibling
    attr_accessor :prevSibling
    attr_accessor :filename
    attr_accessor :startLocation
    attr_accessor :endLocation

    def addChild(child)
        child.parent = self
        if @firstChild.nil?
            @firstChild = child
            @lastChild = child
        else
            @lastChild.nextSibling = child
            child.prevSibling = @lastChild
            @lastChild = child
        end
    end
    
    # Reads the input file to return the original XML of the XML Node.
    def deserialize()
        xml = ""

        if @filename and @startLocation and @endLocation
            lines = File.readlines(@filename)
            startLineNum = @startLocation[:line]
            endLineNum = @endLocation[:line]
           
            for i in startLineNum-1..endLineNum-1 do
                line = lines[i]
                xml += line
            end

            return xml

        else
            puts "invalid locations to deserialize"
            return nil
        end
    end
end

# A node for any XML Element.
class XmlElementNode 
    include XmlNode
    
    def initialize(tag, filename, startLocation)
        @tag = tag
        @filename = filename
        @startLocation = startLocation
        @endLocation = nil
        @attributes = []
        @firstChild = nil
        @lastChild = nil
        @nextSibling = nil
        @prevSibling = nil
        @parent = nil
    end

    attr_reader :tag
    attr_reader :attributes

    def addAttribute(attributeNode) 
        @attributes.push attributeNode
    end

    def getLastAttribute()
        return @attributes[-1]
    end

    # If this Element Node has text stored as a child Text Node, return it.
    def textContent()
        if @firstChild.respond_to?("text")
            return @firstChild.text
        else
            return ""
        end
    end

    # Returns the first child element with matching +tag+
    def getChildWithTag(tag)
        child = @firstChild
        while child do
            if child.respond_to?("tag") and child.tag == tag
                return child
            else
                child = child.nextSibling
            end
        end
        return nil
    end
    

end

# A Text Node stores raw text that occurs between other elements.
class XmlTextNode
    include XmlNode

    def initialize(text, parent = nil)
        @text = text
        @parent = parent
        @firstChild = nil
        @lastChild = nil
        @nextSibling = nil
        @prevSibling = nil
    end

    attr_reader :text

end

# An Attribute Node exists as the child to an Element Node.
# It stores the key and value of one of its parent's attributes.
class XmlAttributeNode
    include XmlNode

    def initialize(parent = nil)
        @key = nil
        @value = nil
        @parent = parent
        @firstChild = nil
        @lastChild = nil
        @nextSibling = nil
        @prevSibling = nil
    end

    attr_accessor :key
    attr_accessor :value

end