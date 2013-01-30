class ResourceProxy

  include Ezproxy #api/ezproxy.rb
  attr_accessor :client
  
  def initialize
    @client = Ezproxy::Client.new
  end
  
  def search(query)
  # Accept string or regexp, but if string convert to regexp.
  query = query.class == Regexp ? query : %r/#{query}/
  #Returns results matching query, e.g. search("pubmed")
    #Array of Mechanize::Page::Links objects
    @q = client.links({:text => query})
  end
 
end