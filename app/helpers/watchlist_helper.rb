require 'byebug'

module WatchlistHelper

    def watchlist
        watchlists = []
        company = {}
       
        current_user.watchlists.each do |watchlist|
            @security_name = watchlist.name
            # browser = Watir::Browser.new(:chrome)
            browser = Watir::Browser.new :chrome, headless: true
            browser.goto("https://www.msn.com/en-my/money/")
            browser.text_field(id:"finance-autosuggest").set @security_name
            browser.send_keys :enter
            sleep 1
            parsed_page = Nokogiri::HTML(browser.html)
            
            
            
            company = {
                ticker: parsed_page.css("div.live-quote-subtitle").text.split.last,
                company_name: parsed_page.css("div.live-quote-title").text.split.first,
                price: parsed_page.css("div.live-quote-bottom-tile span").first.text,
                change_percent: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(2)")[0].text,
                change_price: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(1)")[0].text 
            }
            
            watchlists << company
            #  array << wactlist{}
            browser.close
        end
            @watchlists = watchlists
            
    end

end
