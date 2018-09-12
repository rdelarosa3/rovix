require 'nokogiri'
require 'httparty'
require 'watir'
require 'sentimental'


module WatchlistHelper

    def watchlist
        
        watchlists = []
        company = {}
        scores = []
       
       
        current_user.watchlists.each do |watchlist|
            @security_name = watchlist.name
            opts = {
                headless: true
              }

              if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
                opts.merge!( options: {binary: chrome_bin})
              end 
            # @browser = Watir::Browser.new(:chrome)
            # @browser = Watir::Browser.new :chrome, headless: true
            @browser = Watir::Browser.new :chrome, opts 
            browser.goto("https://www.msn.com/en-my/money/")
            browser.text_field(id:"finance-autosuggest").set @security_name
            browser.send_keys :enter
            sleep 1
            parsed_page = Nokogiri::HTML(browser.html)
            
            
            
            company = {
                ticker: parsed_page.css("div.live-quote-subtitle").text.split.last,
                company_name: parsed_page.css("div.live-quote-title").text.split.first,
                price: parsed_page.css("div.live-quote-bottom-tile span").first.text,
                twitter: parsed_page.css("div.live-quote-subtitle").text.split.last.insert(0,'$'),
                change_percent: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(2)")[0].text,
                change_price: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(1)")[0].text 
            }
            
       

            ########## new sentimental ################
             $analyzer = Sentimental.new
	         $analyzer.load_defaults

            ########## redirect to twitter ################
            url = "https://twitter.com/search?f=tweets&q=#{company[:twitter]}"
            unparsed_page = HTTParty.get(url)
            parsed_page = Nokogiri::HTML(unparsed_page)            
            parsed_page = Nokogiri::HTML(browser.html)
              ########## create tweets array ################
            tweets = parsed_page.css('div.tweet')
            security_tweets = []
            #---- grab each tweet -------#
            tweets.each do |twat|
            tweet = {
                content: twat.css('p.TweetTextSize').text
            }
            security_tweets << tweet
          
            end
           
            ###### set sentiment ##############
            security_tweets.each do |tweet|
                body = tweet[:content] 
                tweet[:sentiment] = $analyzer.sentiment(body)
                tweet[:score] = $analyzer.score(body)
            end

            @tweets = security_tweets

            # create sentiment from tweets #
                negative = 0
                positive = 0
                score = 0
                @tweets.each do |tweet|
                    score = score + tweet[:score]
                    if tweet[:score] < 0
                    negative += 1
                    else
                    positive += 1
                    end
                    
                end
                    
                @positive = (positive.to_f / 20 * 100).round
                @negative = (negative.to_f / 20 * 100).round

            
                scores << @positive
                scores << @negative

                watchlists << company
              #  array << wactlist{}  #
               
                 browser.close
                
            end

                @watchlists = watchlists
                @scores = scores
                
        end
    
end
        
