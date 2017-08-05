#Project: Harvesting von Lernressourcen
#
#File:scraper_mnstep.rb
#
#Kurzbeschreibung: Mit dem Webscraper sollen mediengestuetzte Lehrszenarios aus dem world wide web extrahiert werden
#und in ein Textdokument zur vereinfachten Uebersichtlichkeit uebertragen werden.
#
#Autoren: Swetlana Blank & Stella Ehnis
#


#open necessary gems
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'


#open new project
scraper = Mechanize.new { |agent|
  agent.user_agent_alias = 'Windows Chrome'
}


#conditionally set certificate under Windows.
#If you do not use this line, your commander will show you an ERROR regarding a blocked SSL-certificate 
scraper.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE 


#Mechanize setup to rate limit your scraping to once every half-second. Important!! Or you will be IP banned!
scraper.history_added = Proc.new { sleep 0.5 }


DOMAIN = 'http://serc.carleton.edu/sp/mnstep/activities.html'
	if (DOMAIN == nil) then
		puts "domain not found"
		exit
	end
	puts "domain ok!"


#define all necessary items from CSS Code to get a working scraper
def parse_page(page_content, scraper)
	result = []
	page_content.parser.css('.searchhitdiv').each do |item|
		title_tag = item.search('.searchhit > a')[0];
		title = title_tag.text.strip;
		url = title_tag.attributes['href'].value

		description = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('body').each do |subpage_body| 
				description += subpage_body.search('.serc-content').text.strip.gsub(/  |\t/, " ")
			end
		end

		# Add result to array
		result << {"url": url, "title": title, "scenario-description": description}
	end
	return result
end


#define parser for specific keywords which are put in the searchform
def magic(keyword, scraper)
	result = []
	scraper.get(DOMAIN) do |page|
		form = page.form_with(:class => 'facetedsearch') do |search|
			search['search_text'] = keyword
		end

		result_page = form.submit
		result << parse_page(result_page, scraper)

		if (result_page == nil) then
			puts "no results"
			exit
		end
		puts "results ok!"

		# Parse following pages by the next-page a-tag
		next_link = result_page.parser.css('div.searchnextprev > a')
		result_page.parser.css('div.searchnextprev > a').each do |a_next_link|
			next_url = a_next_link.attribute('href')
			navigation_page = scraper.get(next_url)
			result << parse_page(navigation_page, scraper)

		next_link = navigation_page.parser.css('div.searchnextprev > a')	
		end

		if (next_link == nil) then
			puts "no next link"
			exit
		end
		puts "next link ok"

	end
	return result
end


#print information to json file
def print_file(result, keyword)
	File.open("#{keyword}.json", "w") do |f|
		f.write ('{"domain: http://serc.carleton.edu/sp/mnstep/index.html // language: english // scenarios":')
		f.write(result.to_json)	
		f.write ('}')
	end
end


# ---- main interaction ----
keywords = ["Digital learning", "Computer", "Media based learning", "Computer based learning", "Online"] 
keywords.each do |keyword|
	result = magic(keyword, scraper)
	print_file(result, keyword)
end

if (keywords ==nil) then
	puts "no keywords"
	exit
end
puts "all keywords done"