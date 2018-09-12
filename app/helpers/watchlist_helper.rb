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
            # opts = {
            #     headless: true
            #   }

            #   if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
            #     opts.merge!( options: {binary: chrome_bin})
            #   end 
            # # @browser = Watir::Browser.new(:chrome)
            # # @browser = Watir::Browser.new :chrome, headless: true
            # browser = Watir::Browser.new :chrome, opts 
            # browser.goto("https://www.msn.com/en-my/money/")
            # browser.text_field(id:"finance-autosuggest").set @security_name
            # browser.send_keys :enter
            # sleep 1
            # parsed_page = Nokogiri::HTML(browser.html)
            

            url = "https://www.marketwatch.com/investing/stock/#{@security_name}"
            unparsed_page = HTTParty.get(url)
            parsed_page = Nokogiri::HTML(unparsed_page) 

            company = {
                ticker: @security_name,
                company_name: parsed_page.css("h1.company__name").text, 
                # company_name: parsed_page.css("div.live-quote-title").text.split.first,
                price: parsed_page.css("h3.intraday__price bg-quote").text, 
                # price: parsed_page.css("div.live-quote-bottom-tile span").first.text,
                twitter: "$#{@security_name}",
                change_percent: parsed_page.css("span.change--percent--q").text,
                # change_percent: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(2)")[0].text,
                change_price: parsed_page.css("span.change--point--q").text
                # change_price: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(1)")[0].text 
            }
            
            # browser.close

            ########## new sentimental ################
             $analyzer = Sentimental.new
	         $analyzer.load_defaults

            ########## redirect to twitter ################
            url = "https://twitter.com/search?f=tweets&q=#{company[:twitter]}"
            unparsed_page = HTTParty.get(url)
            parsed_page = Nokogiri::HTML(unparsed_page)            
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
 
            end

                @watchlists = watchlists
                @scores = scores
                
        end
    
end
        
