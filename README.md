--------------------------------------------------------------------------   README   ---------------------------------------------------------------------------------------------

Projekt: Harvesting von Lernressourcen
Datei 1:scraper_lehrer_online.rb
Datei 2: scraper_mnstep.rb

Kurzbeschreibung:
Mit dem Webscraper sollen mediengest�tzte Lehrszenarios aus dem world wide web extrahiert werden
und zur vereinfachten �bersichtlichkeit sowie zur sp�teren Weiterverarbeitung in ein JSON-Dokument �bertragen werden.

Autoren: Swetlana Blank & Stella Ehnis

Juli 2017


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Mindestanforderungen:

Hardware
- PC mit aktuellem Betriebssystem (durchgef�hrt an Windows 7 und Windows 10)

Software
- Browser verh�lt sich wie Google Chrome (durchgef�hrt mit Windows Chrome)
- Interpreter zum Auslesen und Schreiben des Programmcodes (durchgef�hrt mit SciTe und Sublime Text 3)
- Ruby Version: 2.0.0. und 2.3.3 & Rails Version: 5.0.0.1  und 5.0.2 (Download Link: https://rubyinstaller.org/) 
- Notwendige Rubygems / Bibliotheken zur vorherigen Installation:
	
	Schreibweise/Aufrufen im Code		require 'rubygems'
								require 'mechanize'
								require 'nokogiri'
	
	Zum Download					rubygems Version 2.6.10 (Download Link: https://rubygems.org und zugeh�rige Eingabe im Ruby Commander: gem install rubygems)
								mechanize Version 2.7.5 (Download Link:  https://rubygems.org/gems/mechanize und zugeh�rige Eingabe im Ruby Commander: gem install mechanize) 
								nokogiri Version 1.8.0 (Download Link: Download Link:  https://rubygems.org/gems/nokogiri und zugeh�rige Eingabe im Ruby Commander: gem install nokogiri)
						
						
								F�r ein Update der oben genannten Versionen gen�gt der Befehl im Commander:
								gem update --system
	
	
	Kurzbeschreibung: 				Rubygems: stellt als Paketsystem ein Werkzeug zur Verwaltung von Paketen und ein Repositorium f�r deren Verteilung zur Verf�gung.
						
								Nokogiri: Neben Nokogiri�s zahlreichen Funktionen lassen sich HTML/XML, SAX Dateien Auslesen und Dokumente �ber XPath und CSS3-Selektoren suchen.
						
								Mechanize:  Mechanize baut auf Nokogiri auf, erm�glicht Interaktionen mit Webseiten sowie eine automatisierte Navigation.
								Mechanize sendet beispielsweise automatisch Cookies, kann Formulare ausf�llen und weiterf�hrenden Verlinkungen folgen sowie bereits besuchte Pfade tracken.



- Eine geeignete Software zur Ausgabe der extrahierten Ergebnisse zum �ffnen und Lesen von Textdateien sollte ebenfalls vorweg auf dem Computer installiert sein. 
Das gew�nschte Ausgabeprogramm muss im ersten Teil des Programmcodes neben den jeweiligen Gems und Bibliotheken aufgerufen werden. 
Das Programm wurde Testweise durchgef�hrt mit JSON, CSV und Microsoft Word:
						
	Schreibweise im Code				require 'csv'
								require 'json'




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Wichtige Hinweise:


1) Folgende Zeile im Programmcode ist essentiell, um eine m�gliche ERROR-Meldung aufgrund fehlender SSL-Zertifikate zum umgehen:
	
								scraper.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
								

2) Die extrahierten Schlagworte sind auf dem Protal LehrerOnline sowie auf dem Portal MnStep in unten stehender Zeile vorzufinden.
In der beigef�gten Schlagwortliste (PDF) befinden sich weitere Keywords zur Erg�nzung bei Bedarf.
F�r jedes Keyword wird automatisch eine separate JSON Datei angelegt.
Alternative Keywords k�nnen an folgender Stelle ohne Weiteres beliebig ausgetauscht werden:

								keywords = ["Tablet","Digitales Lernen", "Computer", "Medien", "Mobile"] 


!!!Bitte beachten!!! Beim Scraper "scraper_lehrer_online.rb" ist es nicht m�glich, die Keywords "Lehrer" und "Online" in die Suche einzutragen,
da diese im Titel der Homepgage auftauchen, und so ein Error aufgrund von Kollision entsteht.

3) Ausgabe via JSON: Eine doppelte Klammer erscheint in der Ausgabe aufgrund eines doppelten Arrays im Programmcode.
- Keine automatische L�schfunktion der Klammern im Programmcode m�glich, da sich die Anzahl der Zeichen in der Ausgabedatei von Schlagwort zu Schlagwort unterscheiden. 
- Deshalb erfolgt eine manuelle L�schung jeweils einer ge�ffneten und geschlossenen eckigen Klammer zum Beginn und Ende der Ausgabedatei. 


4) Die eingereichten Portale haben kein notwendiges Log-In, um Zugriff auf die Beschreibung der jeweiligen Lernszenarios einzusehen.
Falls dies nachtr�glich eingef�gt werden soll, kann hier die Struktur des folgenden Codestranges helfen.
Hierzu muss au�erdem das Gem "logger" installiert und im Programmcode zu Beginn ebenfalls aufgerufen werden:

								DOMAIN = URL DER INTERNETSEITE
								page = a.get(URL DER STARTSEITE MIT LOGIN FELD) do |page|

									form = page.form_with(:id => 'ID IM CSS CODE DES LOGIN FELDS') do |f|
			
										f['HTML QUELLCODE BEZEICHNUNG DES FORMULAR TEILES[user]'] = 'USERNAME'
										f[' HTML QUELLCODE BEZEICHNUNG DES FORMULAR TEILES[pass]'] = 'PASSWORT'
									end

									login = form.submit
		  
								end

								url = "URL DER ANGEZEIGTEN SEITE NACH MANUELLEM LOG IN"
								page = a.get(url)
									puts page.parser.css('div.KLASSE').text
								results = page.parser.css('div.KLASSE').text
								
						