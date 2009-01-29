# This is for including in models
# because accessing the standard rails view helper methods is difficult
# Taken and adapted from rails/actionpack/lib/action_view/helpers/text_helper.rb
#
module TextileToHtml
  AUTO_LINK_RE = /
                  (                       # leading text
                    <\w+.*?>|             #   leading HTML tag, or
                    [^=!:'"\/]|           #   leading punctuation, or 
                    ^                     #   beginning of line
                  )
                  (
                    (?:http[s]?:\/\/)|    # protocol spec, or
                    (?:www\.)             # www.*
                  ) 
                  (
                    ([\w~]+:?[=?&\/.-]?)*    # url segment
                    \w+[\/]?              # url tail
                    (?:\#\w*)?            # trailing anchor
                  )
                  ([[:punct:]]|\s|<|$)    # trailing text
                  /x
  
  def textile_to_html(textile)
    html = RedCloth.new( textile, [:filter_html] ).to_html(:textile)
    html = auto_link_urls( html )
    html = escape_javascript_links( html )
    html
  end
  
  private 
  
  def escape_javascript_links( html )
    html.gsub %r{(href=['"])\s*javascript:.*?(['"][ >])}, '\1\2'
  end
  
  def auto_link_urls(text)
    text.gsub(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $5
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{b + c}</a>#{d})
      end
    end
  end
end