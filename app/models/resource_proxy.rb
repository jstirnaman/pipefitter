class ResourceProxy

  include Ezproxy #api/ezproxy.rb

  def initialize
    @client = Ezproxy::Client.new
  end
  
  def search(query)
  #Returns search results for query, e.g. search("pubmed")
    #Array of Mechanize::Page::Links objects
    @q = @client.search({:name => %r/.*#{query}.*/})
  end
 
end