# DOM Parsing

## Execution Instructions

Run `$ ./runner.rb` to execute the tests.  Each test produces output in `test/test[...]_output.xml`.
The `test/test_[...].xml` files contain the expected output for each test.

## Overview

The main components of the XML Parser are the the input reader, the lexer, the parser, and the XML Node tree.
In combination, these components allow for an XML file to be read and its data stored in nodes in the tree.
Representing the document as a tree allows for simple tree traversal to access whatever data we are interested in.


When instantiated with a filename, the XmlDoc class translates the provided file into a tree structure
and provides methods for querying the tree for specific elements.

The file is translated from xml to tree by the input reader, lexer, and parser.
The input reader sends characters one by one to the lexer, which constructs tokens.  
Each token has a type, which is determined by the structure of the input characters,
and a value, which is a series of characters. For example, a token might be constructed
from a series of input characters resulting in the type of "tag" and a value of "book".

Once the entire file is read, the tokens are sent to the parser, which composes the 
tokens into XML nodes and constructs the tree.  For example, the parser might read
a series of tokens: a "tag" token with value "author", an "inner_text" token with value
"Ralls, Kim", and an "end-tag" token with value "author". From these it will construct
an Element Node with a tag of "author" that points to a child Text Node with a text value
of "Ralls, Kim".  

Once the tree is constructed, the document is ready to accept queries. 
If a query of `getElementsByTagName("author")` is called, the XmlDoc will 
traverse the tree looking for all Element Nodes with a tag of "author" and return them.
A filter can be applied to further specify query details.  Defining a filter with
`filter = QueryFilter.new({:noDuplicates => ""})` and passing that along with the query
tells the XmlDoc to remove any duplicate occurences of an author from the result.