# The Parser receives tokens from the lexer and uses them to construct XML nodes 
class Parser
    
    def initialize()
        @root = nil
    end

    # Constructs a tree of XML nodes representing the input document.
    # Reads multiple tokens to construct a single XML Node,
    # e.g. reads an "attribute" token and an "attribute_value" token to construct an XmlAttributeNode
    # and add it to the tree.
    # @return the root of the XML node tree. 
    def generateNodeTree(tokens)
        currentNode = nil
        processingNode = nil

        for token in tokens
            type = token[:type]
            value = token[:value]
            filename = token[:filename]
            line = token[:line]
            col = token[:col]

            case type

            when "processing_instruction"
                currentNode = XmlElementNode.new(value, filename, {:line => line, :col => col})

            when "attribute"
                attributeNode = XmlAttributeNode.new(currentNode)
                attributeNode.key = value
                currentNode.addAttribute(attributeNode)

            when "attribute_value"
                attributeNode = currentNode.getLastAttribute()
                attributeNode.value = value

            when "end_processing_instruction"
                processingNode = currentNode
                currentNode = nil

            when "inner_text"
                textNode = XmlTextNode.new(value)
                if currentNode.nil?
                    if !processingNode.nil?
                        processingNode.addChild(textNode)
                    end
                else
                    currentNode.addChild(textNode)
                end

            when "tag"
                elementNode = XmlElementNode.new(value, filename, {:line => line, :col => col})

                if @root.nil?
                    @root = elementNode
                end

                if currentNode.nil?
                    currentNode = elementNode
                else
                    currentNode.addChild(elementNode)
                    currentNode = elementNode
                end

            when "end-tag"
                if value == currentNode.tag
                    currentNode.endLocation = {:line => line, :col => col}
                    currentNode = currentNode.parent
                else
                    puts "syntax error: end tag #{value} does not match previous tag"
                end
            end


        end
        return @root
    end
end