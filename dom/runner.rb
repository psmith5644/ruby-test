#!/usr/bin/env ruby -w

# Run this script in order to see if your code is doing the right thing.
# Feel free to modify anything in here

require '../test_support'
require './src/xml_doc.rb'

# Demonstrate that your parser can perform (or enable other code to perform) the following tasks:
# Find all book elements - return a list of xml book elements
# Find all author elements - return a list of xml author elements
# Find the book with id of bk103 - returns a single book element
# Find all book elements in the Fantasy genre - returns a list of book elements


it "can find all book elements" do
    xmlDoc = XmlDoc.new("books.xml")
    xml = xmlDoc.getElementsByTagName("book")

    File.write("./test/test_books_output.xml", xml)

    assert xml.strip == File.read("./test/test_books.xml").strip
end


it "can find all author elements" do
    xmlDoc = XmlDoc.new("books.xml")

    filter = QueryFilter.new({:noDuplicates => ""})
    xml = xmlDoc.getElementsByTagName("author", filter)
    File.write("./test/test_authors_output.xml", xml)

    assert xml.strip == File.read("./test/test_authors.xml").strip
end

it "can find a book with id of bk103" do
    xmlDoc = XmlDoc.new("books.xml")

    xml = xmlDoc.getElementById("bk103")
    File.write("./test/test_bk103_output.xml", xml)

    assert xml.strip == File.read("./test/test_bk103.xml").strip
end

it "can find all book elements in the Fantasy genre" do 
    xmlDoc = XmlDoc.new("books.xml")

    filter = QueryFilter.new({:containsChildElementWithMatchingText => {:tag => "genre", :textContent => "Fantasy"}})
    xml = xmlDoc.getElementsByTagName("book", filter)
    File.write("./test/test_fantasy_output.xml", xml)

    assert xml.strip == File.read("./test/test_fantasy.xml").strip
end