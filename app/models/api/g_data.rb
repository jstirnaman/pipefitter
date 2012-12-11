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
			# First worksheet
			@worksheet = session.spreadsheet_by_key(spreadsheet_key).worksheets[0]
		end
		
		def column(col)
			self.worksheet.rows.map {|r| r[col-1]}
		end
		
		def all
		  # Gets all content
		  self.worksheet.rows
		end
	end
end