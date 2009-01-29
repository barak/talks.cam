require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < Test::Unit::TestCase
  fixtures :documents
    
  def test_xss_prevention
     document = Document.new
     document.name = "Test <tags> are </tags> <escaped/>"
     document.save
     assert_equal "test &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;", document.name
          
     document.body = "A <hr/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>"
     document.save
     assert_equal "A <hr/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>", document.body
     assert_equal "<p>A   <a href=\"\">Hello</a></p>", document.html
     
   end
  
end
