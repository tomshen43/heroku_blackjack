require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',:path => '/',:secret => 'random'

BLACKJACKAMOUNT = 21
DEALER_MIN_HIT = 17

helpers do

  def calculate_amount(cards)
    @sum=0
   arr=cards.map{|i| i[0]}
   arr.each do |v|
     if v == 'A'
      @sum +=11
    elsif v.to_i == 0
      @sum+=10
    else
      @sum +=v.to_i
    end
  end
  arr.select{|a| a=='A'}.count.times do
    @sum-=10 if @sum > BLACKJACKAMOUNT
  end
   @sum
  end

  def card_image(card)
    suit = case card[1]
      when 'Diamond' then 'diamonds'
      when 'Spade' then 'spades'
      when 'Club' then 'clubs'
      when 'Heart' then 'hearts'
    end
    #if card.any? {|i| ['J','Q','K','A'].include?()}
    if ['J','Q','K','A'].include?(card[0])
      face = case card[0]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    else 
      face = card[0]
    end
    "<img src='/images/cards/#{suit}_#{face}.jpg' class='card_image'>"
  end

  def winner(msg)
    @hit_or_stay_button = false
    @play_again = true
    @winner= "You Won! #{msg}"
    calc_bank(session[:bet],session[:bank],2)
  end

  def loser(msg)
    @hit_or_stay_button = false
    @play_again = true
    @loser= "You Lost! #{msg}"
  end

  def tie(msg)
    @hit_or_stay_button = false
    @play_again = true
    @winner= "#{msg}"
    calc_bank(session[:bet],session[:bank],1)  
  end

  def calc_bank(bet,bank,mul)
    session[:bank]+=mul.to_i*(session[:bet].to_i)
  end

end

before do 
  @hit_or_stay_button = true
end


get '/' do
  session[:bank] = 500
  erb :set_name 
end

post '/set_name' do
  session[:player_name]=params[:player_name]
  if params[:player_name].empty?
    @error= "<h2>You must enter a name</h2>"
    halt erb(:set_name)
  end  
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if  params[:bet].to_i<=0 || params[:bet].to_i > session[:bank]
    @error= "<h2>You must make a bet that is greater than 0</h2>"
    halt erb(:bet)
  end
  session[:bet]=params[:bet]
  session[:bank]-= session[:bet].to_i
  redirect '/game'
end

get '/game' do
  session[:turn]='player'
  SUITS = ['Diamond','Spade','Club','Heart']
  FACE_VALUE = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
  session[:deck] = FACE_VALUE.product(SUITS).shuffle
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_total] = calculate_amount(session[:player_cards])
  if session[:player_total] == BLACKJACKAMOUNT
    winner("#{session[:player_name]} hit a blackjack ")
  end
  erb :game
end

post '/game/hit' do
  session[:player_cards] << session[:deck].pop
  session[:player_total] = calculate_amount(session[:player_cards])
  if session[:player_total] == BLACKJACKAMOUNT
    winner("#{session[:player_name]} hit a blackjack ")
  elsif session[:player_total] > BLACKJACKAMOUNT
    loser("#{session[:player_name]} busted")
  end
  erb :game, layout: false
end


post '/game/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  @hit_or_stay_button = false
  @success = "#{session[:player_name]} chose to stay"
  session[:turn]='dealer'
  session[:dealer_total] = calculate_amount(session[:dealer_cards])
  if session[:dealer_total] == BLACKJACKAMOUNT
    loser("dealer hit a blackjack")
  elsif session[:dealer_total] > BLACKJACKAMOUNT
    winner("dealer busted with #{session[:dealer_total]}")
  elsif session[:dealer_total] < DEALER_MIN_HIT
    @dealer_hit = true
  else
    redirect '/game/compare'
  end
  erb :game, layout: false


end

post '/game/dealer/hit' do 
  session[:dealer_cards]<<session[:deck].pop
  redirect 'game/dealer'
end

get '/game/compare' do
  @hit_or_stay_button = false
  if session[:dealer_total]>session[:player_total]
    loser("dealer has #{session[:dealer_total]} and you have #{session[:player_total]}")
  elsif session[:dealer_total]<session[:player_total]
    winner("dealer has #{session[:dealer_total]} and you have #{session[:player_total]}")
  else
    tie("it is a tie")
  end
  erb :game, layout: false
end

get '/game_over' do
  erb :game_over
end



















