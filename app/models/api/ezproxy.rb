# Scrapes your EZProxy /menu page to find the list of configured resources and URLs.
module Ezproxy

  class Client
    include CasMechanizer
    
    attr_accessor :agent, :store, :page
    EZPROXY_BASE_URL = API_CONFIG['EZPROXY']['BASE_URL']
    
    def initialize()
      @agent = Mechanize.new
      @agent.log = Logger.new "mechanize-ezproxy.log"
      @agent.user_agent_alias = 'Mac FireFox'
      # Store CAS credentials.
      @store = cas_auth_store
      # Return a Mechanize Page object from the content at URL.
      #@page = @agent.get(API_CONFIG['EZPROXY']['BASE_URL']+'/menu')
      @page = mechanize_authentication(EZPROXY_BASE_URL + '/menu')
    end
    
    def links(options = {:href => %r/#{EZPROXY_BASE_URL}/})
      # Mechanize returns array of matching Mechanize::Page::Link objects with a.content, a.href
      links = page.links_with(options)
    end
    
    def links_to_hash(options)
      links = links(options).collect do |l|
				h = Hash.new
				h[:text] = l.text
				h[:uri] = l.uri # Returns href attribute as a fully parsed uri.
				h[:target] = target_domain(l.uri)
				h
		  end
    end
    
    def target_domain(uri)
      URI(uri.query.sub('url=', '')) # Return url parameter as a fully parsed uri.
    end

    private

    def format_id_param(id)
      Array(id).join('/')
    end
    
    def hash_from_menu
    # Parse the HTML doc and find the paragraph element containing the list of links.
      #body = doc.css('body')
      #menu = body.xpath("/p[a[contains(@href, '/login?url=')]]")
    end
  end
end