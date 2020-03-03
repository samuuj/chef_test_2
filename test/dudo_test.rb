require 'minitest/autorun'
require '../scripts/dudo.rb'

class TestDudo < Minitest::Test
  
  def setup
    @player_list = []
    @player_list << { id: "001", name: "name_1", die_count: 2, type: "human", dice_roll: [3,3], bid: {dice_number: 3, dice_count: 4} }
    @player_list << { id: "002", name: "name_2", die_count: 0, type: "human", dice_roll: [1,4], bid: {dice_number: 3, dice_count: 2} }
  end

  def test_dice_roll_returns_array_of_two_numbers
    dudo = Dudo.new.roll_dice(player_list: @player_list)
    assert_equal 2, dudo[0][:dice_roll].count
  end

  def test_dudo_call_returns_true
    dudo = Dudo.new.dudo_called
    assert dudo
  end

  def test_that_player_with_no_dice_is_returned
    dudo = Dudo.new.check_dice_count(player_list: @player_list)
    assert_equal "002", dudo[0][:id]
    assert_equal "name_2", dudo[0][:name]
  end

  def test_that_random_player_is_selected
    dudo = Dudo.new.starting_player(player_list: @player_list)
    assert dudo.is_a?(Hash)
  end

  def test_that_bids_are_checked_and_player_returned
    dudo = Dudo.new.check_bids(player_list: @player_list)
    assert_equal "001", dudo[0][:id]
    assert_equal "name_1", dudo[0][:name]
  end
end