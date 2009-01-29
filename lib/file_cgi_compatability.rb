# A wrapper for compatability between Files and cgi uploads
module FileCGICompatability
 def size
   File.size(path)
 end
end