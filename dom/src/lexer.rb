# The Lexer receives characters from the xml file and produces tokens that are sent to the parser.
class Lexer
    def initialize() 
        @state = "default"
        @token = {:type => "", :value => [], :filename => nil, :line => nil, :col => nil}
        @tokens = []
    end

    attr_reader :tokens

    # Resets the token to its initial state so it can be used to create a new token.
    def resetToken(type = @state)
        @token[:type] = type
        @token[:value] = []
    end

    # Adds the current token to the list of tokens that will be sent to the Parser.
    def addToken() 
        @token[:value] = @token[:value].join("")
        token_copy = @token.dup
        @tokens.push token_copy
        resetToken()
    end

    # Adds a character to the current token.
    def appendToToken(char)
        @token[:value].push char
    end

    # Sets the location of the start or end of the current token, depending on the token type.
    def setLocation(filename, line, col)
        @token[:filename] = filename
        @token[:line] = line
        @token[:col] = col
    end


    # Creates tokens, given characters from the input reader.
    # May add characters to the current token or create a new token depending on the received character.
    def update(char, filename, line, col)

        case @state

        when "default"
            if char == "<"
                @state = "tag"
                setLocation(filename, line, col)
            elsif char != "<" and char != " "
                @state = "inner_text"
                appendToToken(char)
            end
        
        when "tag"
            if char == " "
                @state = "attribute"
                addToken()
            elsif char == ">"
                @state = "default"
                addToken()
            elsif char == "/"
                @state = "end-tag"
                resetToken()
            elsif char == "?"
                @state = "processing_instruction"
                resetToken()
            else
                appendToToken(char)
            end


        when "attribute"
            if char == "="
                @state= "pre_attribute"
                addToken()
            else
                appendToToken(char)
            end

        when "pre_attribute"
            if char == "\""
                @state = "attribute_value"
                resetToken("attribute_value")
            end

        when "attribute_value" 
            if char == "\""
                @state = "mid-tag"
                addToken()
            else
                appendToToken(char)
            end

        when "inner_text"
            if char == "<"
                @state = "tag"
                setLocation(filename, line, col)
                addToken()
            else 
                appendToToken(char)
            end

        when "mid-tag"
            if char == " "
                @state = "attribute"
                resetToken()
            elsif char == ">"
                @state = "default"
                resetToken()
            elsif char == "?"
                @state = "end_processing_instruction"
                resetToken()
            end

        when "end-tag"
            if char == ">"
                @state = "default"
                setLocation(filename, line, col)
                addToken()
            else
                appendToToken(char)
            end

        when "processing_instruction"
            if char == " "
                @state = "attribute"
                addToken()
            else
                appendToToken(char)
            end
        
        when "end_processing_instruction"
            if char == ">"
                @state = "default"
                addToken()
            end

        end

        # update the token
        @token[:type] = @state

        return @state
    end

end