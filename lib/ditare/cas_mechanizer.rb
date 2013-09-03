module CasMechanizer

	def mechanize_authentication(target_url)
	  @store = cas_auth_store
 		user, pass = @store.credentials_for PERSONALIZE_CONFIG['CAS_LOGIN_FORM'], 'other'
 		page = @agent.get(target_url)
		cas_auth_form = page.form('login_form')
		unless cas_auth_form.nil?
			cas_auth_form.username = user
			cas_auth_form.password = pass
			page = @agent.submit(cas_auth_form)
		end
		return page
	end
	
	def cas_auth_store
	  store = Mechanize::HTTP::AuthStore.new
    store.add_auth PERSONALIZE_CONFIG['CAS_LOGIN_FORM'], PERSONALIZE_CONFIG['CAS_USER'], PERSONALIZE_CONFIG['CAS_PASSWORD']  
	end
	

end