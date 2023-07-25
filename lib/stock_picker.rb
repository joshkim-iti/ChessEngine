def stock_picker(stock_prices)
    temp_profit = 0 #stock_prices[1] - stock_prices[0]
    max_profit = 0 #stock_prices[1] - stock_prices[0]
    max_days = [0,0]
    temp_days = [0,0]
    stock_prices.each_with_index do |price, index|
        if price < stock_prices[temp_days[0]]
            #restart and check if temp profit is more than max
            if max_profit < temp_profit
                max_profit = temp_profit
                max_days[0] = temp_days[0]
                max_days[1] = temp_days[1]
            end
            temp_days[0] = index;
            temp_days[1] = index;
        else
            temp_profit = price - stock_prices[temp_days[0]]
            puts "profit is " + temp_profit.to_s
            temp_days[1] = index;      
            if max_profit < temp_profit
                max_profit = temp_profit
                max_days[0] = temp_days[0]
                max_days[1] = temp_days[1]
            end      
        end
    end
    max_days
end

puts stock_picker([17,3,6,9,15,8,6,1,10])