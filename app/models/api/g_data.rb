# Using Google Drive gem.
module GData
  class Client
		# List of Database Names and locally-assigned Database Subjects in a Google Spreadsheet.
		attr_accessor :worksheet
		def initialize(spreadsheet_key)
			# Logs in.
			# You can also use OAuth. See document of
			# GoogleDrive.login_with_oauth for details.
			session = GoogleDrive.login(API_CONFIG['GOOGLE_DRIVE']['EMAIL'], API_CONFIG['GOOGLE_DRIVE']['PASSWORD'])
			# First worksheet as a list. Lets you reference columns by headers in first row.
			# e.g. client.worksheet.keys # => ["database_name", "local_subjects", "oclc_id"]
			# e.g. client.worksheet.each {|r| p r['database_name']}
			@worksheet = session.spreadsheet_by_key(spreadsheet_key).worksheets[0]
		end		
		
		def all
		  # Gets all content as array of hash. Column names are keys.
		  self.worksheet.list.to_hash_array
		end
	end
end