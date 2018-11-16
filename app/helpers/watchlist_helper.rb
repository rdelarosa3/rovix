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
            # herouku browser
            opts = {
                headless: true
              }

              if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
                opts.merge!( options: {binary: chrome_bin})
              end 
            security_name = security_name
                @browser = Watir::Browser.new :chrome, opts 

                # local browsers
             # @browser = Watir::Browser.new(:chrome)
                # local headless
            # @browser = Watir::Browser.new :chrome, headless: true

            url = "http://thestockmarketwatch.com/stock/?stock=#{@security_name}"
            @browser.goto(url)
 
            parsed_page = Nokogiri::HTML(@browser.html)
            company = {
                ticker: @security_name,
                company_name: parsed_page.css("h1.company__name").text,
                price: @browser.execute_script("return $('#lastPrice').children('.qmjsright').html()"), 
                twitter: "$#{@security_name}",
                change_price: @browser.execute_script("return $('#changePctAndPrice').children('span')[0].outerText"),
                change_percent: @browser.execute_script("return $('#changePctAndPrice').children('span')[1].outerText")
                # change_percent: @browser.execute_script("return $('#changePctAndPrice').children().get()[3].outerText"),            
                # change_price: @browser.execute_script("return $('#changePctAndPrice').children().get()[1].outerText")
            }
            
            @browser.close

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
        
