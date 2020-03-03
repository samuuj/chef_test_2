#!/usr/bin/env ruby

# split into classes or modules: Bid, Roll, Round?

class Dudo
  HUMAN_PLAYER = "human".freeze
  COMPUTER_PLAYER = "computer".freeze

  def initialize
    @players = 1
    @starting_die = 2
    @game_die = 4
  end

  attr_reader :players, :starting_die, :game_die, :player_list, :player_bids

  def start_game
    @player_list = []
    players.times do |p|
      puts "Enter Name:"
      name = gets.chomp
      player_list << {id: "001", name: name, die_count: starting_die, type: "human"}
    end
    player_list << {id: "002", name: "Computer 1", die_count: starting_die, type: "computer"}
    start_round(player_list: player_list)
  end

  def start_round(player_list:)
    puts "\n----Round Starting----"
    roll_dice(player_list: player_list)
    start_first_round

    loop do
      puts "\n----Round Starting----"
      player_list.each do |pl|
        return if check_dice_count(player_list: player_list).any?
        puts "\nIt's #{pl[:name]}'s turn!"
        pl[:type] == "computer" ? computer_bid(player: pl) : player_bid(player: pl)
      end
      dudo_call(player_list: player_list)
    end
  end

  def roll_dice(player_list:)
    player_list.each do |p|
      results = []
      p[:die_count].times { |d| results << rand(1..6) }
      p[:dice_roll] = results
      puts "\nYou rolled #{results}" if p[:type] == HUMAN_PLAYER
    end
  end

  def start_first_round
    player_starting = starting_player(player_list: player_list)
    puts "\n#{player_starting[:name]} is starting first!"
    player_starting[:bid] = player_starting[:type] == COMPUTER_PLAYER ? computer_bid(player: player_starting) : player_bid(player: player_starting)

    player_list[player_list.index(player_starting)+1..-1].each do |p|
      puts "#{p[:name]} is starting!"
      p[:bid] = p[:type] == "computer" ? computer_bid(player: p) : player_bid(player: p)
    end
    dudo_call(player_list: player_list)
  end

  def starting_player(player_list:)
    player_list.sample
  end

  def check_dice_count(player_list:)
    losing_player = []
    losing_player.concat player_list.select { |p| p[:die_count] == 0 }
    puts "Losing Player: #{losing_player[0][:name]}" if losing_player.any?
    losing_player
  end

  def computer_bid(player:)
    computer_bid = {}
    dice_array = player[:dice_roll]

    # rand select a rolled dice number
    bid_dice_number = dice_array.sample

    # leaves array with die that dont have the bid dice number so it isnt included in overall count
    unplayable_dice = dice_array - [bid_dice_number]

    # max die currently in play
    max_die = game_die - unplayable_dice.count.to_i
    bid_count_number = rand(1..max_die)

    computer_bid[:dice_number] = bid_dice_number
    computer_bid[:dice_count] = bid_count_number
    puts "#{player[:name]} has bid dice number: #{bid_dice_number} for a count of #{bid_count_number}"
    computer_bid
  end

  def player_bid(player:)
    player_bid = {}
    puts "Place a bid #{player[:name]}, your current roll is #{player[:dice_roll]}"

    dice_array = player[:dice_roll]

    puts "Enter Dice Number:"
    bid_dice_number = gets.chomp
    input_die_num = Integer(bid_dice_number) rescue false
    until input_die_num
      puts "Please enter a number"
      bid_dice_number = gets.chomp
      input_die_num = Integer(bid_dice_number) rescue false
    end

    unplayable_dice = dice_array - [bid_dice_number]
    max_die = game_die - unplayable_dice.count.to_i

    puts "Enter Dice Count:"
    bid_count_number = gets.chomp.to_i
    until bid_count_number <= max_die
      puts "Please enter a number less or equal to #{max_die}"
      bid_count_number = gets.chomp.to_i
    end

    player_bid[:dice_number] = bid_dice_number.to_i
    player_bid[:dice_count] = bid_count_number.to_i
    player_bid
  end

  def dudo_call(player_list:)
    puts "Do you want to call Dudo? (y/n)"
    dudo_input = gets.chomp.downcase
    dudo_result = case dudo_input
                  when "y"
                    dudo_called
                  end
    check_bids(player_list: player_list) && return if dudo_result
  end

  def dudo_called
    puts "Dudo!"
    true
  end

  def check_bids(player_list:)
    dice_rolled = []
    @player_bids = []
    player_list.each do |p|
      dice_rolled.concat p[:dice_roll]
      bid = p.dig(:bid)
      next if bid.nil?
      dice_array = Array.new(bid[:dice_count], bid[:dice_number])
      player_bids << {name: p[:name], dice_array: dice_array}
    end

    player_bids.each do |pb|
      remaining = dice_rolled - pb[:dice_array]
      pb[:remaining_dice] = remaining.count
    end

    if player_bids[0].dig(:remaining_dice) < player_bids.dig(1, :remaining_dice).to_i
      print_loser(player: player_bids[1])
      lose_dice(player_list: player_list, player: player_bids[1])
    else
      print_loser(player: player_bids[0])
      lose_dice(player_list: player_list, player: player_bids[0])
    end
  end

  def print_loser(player:)
    puts "----------***----------"
    puts "#{player[:name]} lost this round"
    puts "----------***----------"
    puts "----Round End----"
  end

  def lose_dice(player_list:, player:)
    losing_player = player_list.select { |p| p[:name] == player[:name] }
    losing_player[0][:die_count] = losing_player[0][:die_count] - 1
    losing_player
  end
end
