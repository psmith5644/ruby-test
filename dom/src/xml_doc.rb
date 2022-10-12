require './src/lexer'
require './src/parser'
require './src/xml_node'
require './src/query_filter'

# A representation of an XML document.  Creates a tree of XML nodes to organize the file's data.
# Provides methods to query the XML document for data. 
class XmlDoc

    def initialize(filename)
        @filename = filename
        @root = nil
        serializeDoc()
    end

    # Returns the xml for the element with matching +id+ attribute
    def getElementById(id)
        node = getNodeById(id)
        xml = node.deserialize()
        return xml
    end


    # Helper function to 'getElementById.' Traverses the tree to return the XML node with matching +id+ attribute
    def getNodeById(id) 
        currentNode = @root
        
        while currentNode do
            # check currentNodeent node's attritbutes to see if it has the matching id
            if currentNode.respond_to?("attributes")
                attributes = currentNode.attributes
                for attribute in attributes do
                    if attribute.key == "id" and attribute.value == id
                        return currentNode
                    end
                end
            end
            
            # traverse to the next node: either the child, next sibling, or parent's next sibling
            currentNode = getNextNode(currentNode)
        end
    end

    # Finds all nodes with matching +tag+ that meet the filter requirement and returns them as a list in an xml string
    # The filter can be set, for example, to only retrieve books with a '<genre>' tag with the text 'Fantasy' 
    def getElementsByTagName(tag, filter = nil)
        matchingNodes = getNodesByTagName(tag, filter)

        xml = ""

        if filter and filter.options.has_key?("noDuplicates".to_sym)
            matchingNodes.each do |key, value|
                xml += value.deserialize()
            end
        else
            for node in matchingNodes do
                xml += node.deserialize()
            end
        end
    
        return xml
    end
    
    # Traverses the XML tree to find all elements with matching +tag+ and meeting the requirements of the +filter+
    # @return a list of XML nodes with matching +tag+
    def getNodesByTagName(tag, filter)
        currentNode = @root
        matchingNodes = []
            while currentNode do
                doesCurrentNodeMatch = false

                if currentNode.respond_to?("tag")
                    if currentNode.tag == tag
                        # applies the filter if it is set to only retrieve elements with specific child elements
                        if filter and filter.options.has_key?("containsChildElementWithMatchingText".to_sym)
                            filterParams = filter.options[:containsChildElementWithMatchingText]
                            childTag = filterParams[:tag]
                            childTextContent = filterParams[:textContent]
                            matchingChild = currentNode.getChildWithTag(childTag)
                            if matchingChild and matchingChild.textContent == childTextContent  
                                matchingNodes.push currentNode
                                doesCurrentNodeMatch = true
                            end
                        else
                            matchingNodes.push currentNode
                            doesCurrentNodeMatch = true
                        end
                    end
                end
                
                # if the current node is a match, skip its children
                if doesCurrentNodeMatch
                    currentNode = getNextNonChildNode(currentNode)
                else
                    currentNode = getNextNode(currentNode)
                end
            end


        # if the filter is set to do so, remove duplicates of whatever tag is being queried for
        if filter and filter.options.has_key?("noDuplicates".to_sym)
            filteredNodes = {}
            for node in matchingNodes do 
                if !filteredNodes.has_key?(node.textContent)
                    filteredNodes[node.textContent] = node
                end
            end
            return filteredNodes
        end

        return matchingNodes
    end


    # Creates a tree of XML nodes representing the document.
    def serializeDoc()
        lines = File.readlines(@filename)

        lexer = Lexer.new

        for lineNum in 1..lines.length()
            line = lines[lineNum-1]
            chars = line.chars
            
            for col in 1..chars.length()
                char = chars[col-1]
                lexer.update(char, @filename, lineNum, col)
            end
        end

        parser = Parser.new
        @root = parser.generateNodeTree(lexer.tokens)
    end

    # Returns the next node to visit when traversing the tree of XML nodes.
    def getNextNode(currentNode)
        if currentNode.firstChild
            currentNode = currentNode.firstChild
        elsif currentNode.nextSibling
            currentNode = currentNode.nextSibling
        elsif currentNode.parent and currentNode.parent.nextSibling
            currentNode = currentNode.parent.nextSibling
        else
                return nil
        end
        return currentNode
    end

    # Returns the next node to visit when traversing the tree of XML nodes, but skips the current node's children.
    def getNextNonChildNode(currentNode)
        if currentNode.nextSibling
            currentNode = currentNode.nextSibling
        elsif currentNode.parent and currentNode.parent.nextSibling
            currentNode = currentNode.parent.nextSibling
        else
            return nil
        end
        return currentNode
    end

end





    


