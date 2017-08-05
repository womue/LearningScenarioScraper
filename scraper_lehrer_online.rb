#Project: Harvesting von Lernressourcen
#
#File:scraper_lehrer_online.rb
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


DOMAIN = 'https://www.lehrer-online.de'
	if (DOMAIN == nil) then
		puts "domain not found"
		exit
	end
	puts "domain ok!"


#define all necessary items from CSS Code to get a working scraper
def parse_page(page_content, scraper)
	result = []
	page_content.parser.css('.kind-unit').each do |item|
		title_tag = item.search('.text > a')[0];
		title = title_tag.text.strip;
		url = title_tag.attributes['href'].value
		date = item.search('.date').text.strip

		description = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('article').each do |subpage_article|
				description += subpage_article.search('.short').text.strip.gsub(/  |\t/, " ")
				subpage_article.search('.summary', '.description').each do |subpage_paragraph|
					description += subpage_paragraph.text.strip.gsub(/  |\t/, " ")
					description += "\n\n"
				end
			end
		end
		
		unitplan = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('article').each do |subpage_article|
				unitplan += subpage_article.search('.unitplan').text.strip.gsub(/  |\t/, " ")
				unitplan += "\n\n"
			end
		end
		
		didactic = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('article').each do |subpage_article|
				didactic += subpage_article.search('.didactic').text.strip.gsub(/  |\t/, " ")
				didactic += "\n\n"
			end
		end
		
		expertise = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('article').each do |subpage_article|
				expertise += subpage_article.search('.expertise').text.strip.gsub(/  |\t/, " ")
				expertise += "\n\n"
			end
		end
		
		material = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('.link-box').each do |subpage_link_box|
				material += subpage_link_box.search('.text').text.strip.gsub(/  |\t/, " ")
				material += "\n\n"
			end
		end		

		linkzui = ""
		scraper.get(url) do |subpage|
			subpage.parser.css('.text > a').each do |subpage_text| 
				linkzui += subpage_text.attributes['href'].value
				linkzui += "\n\n"			
			end 
		end
		
		# Add result to array
		result <<  {"url": url, "title": title_tag, "date": date, "scenario description": description, "unitplan": unitplan, "didactical and methodical comment": didactic, "competencies": expertise, "additional material": material + linkzui}
	end 
	
	#puts result -> to get the information output in your commander 
	return result
end


#define parser for specific keywords which are put in the searchform
def magic(keyword, scraper)
	result = []
	scraper.get(DOMAIN) do |page|
		form = page.form_with(:class => 'searchform') do |search|
			search['tx_losearch_search[query]'] = keyword
		end
		
		result_page = form.submit
		result << parse_page(result_page, scraper)
		
		if (result_page == nil) then
			puts "no results"
			exit
		end
		puts "results ok!"
	
		#Parse all following pages by the next-page a-tag
		next_link = result_page.parser.css('nav.pagebrowser li.next a')
		while next_link.size > 0 do
			next_url = next_link.attribute('href')
			navigation_page = scraper.get(next_url)
			result << parse_page(navigation_page, scraper)
	
			next_link = navigation_page.parser.css('nav.pagebrowser li.next a')
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
		f.write ('{"domain: www.lehrer-online.de // language: german // scenarios":')
		f.write(result.to_json)
		f.write ("}")
	end
end


#---- main interaction ----
keywords = ["Mobile", "Handy", "Digitales Lernen", "Computer", "Medien"]
keywords.each do |keyword|
	result = magic(keyword, scraper)
	print_file(result, keyword)
end

if (keywords ==nil) then
	puts "no keywords"
	exit
end
puts "all keywords done"