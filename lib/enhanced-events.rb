#--
# Enhanced Events v2.1 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script adds in some new features for events, including extra conditions
# (such as script calls or requiring more than one actor to be in the party),
# moving like a boat, ship, or airship, and changed passability so that events
# set as Below Characters or Above Characters no longer block the movement of
# events set as Same as Characters, unless they include a certain tag in a
# Comments box. v2.0 adds in the ability to alter the effective size of an event
# for passability and activation as well as the ability to adjust the event's
# draw position.
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
#   SES Core v2.2 or higher.
# 
# **Known Incompatibilities:**
#  None, though it contains some redefinitions so some may occur if this script
# is below another script that aliases the same method, or if it is above
# another script that redefines that method. A full list of redefinitions is
# included at the bottom of my comments.
# 
# Usage
# -----------------------------------------------------------------------------
#   This script is controlled through tags placed in comments boxes on event
# pages as well as through the Conditions hash in the `SES::Events`
# module. Instructions for the hash are detailed in the module itself, while
# information about the tags is provided here.
# 
# ### Event Comment Tags:
# 
# `<Adjusted !XY!: !Val!>`
# 
# Place this in a comments box to adjust the position in which an event is
# drawn. You may have up to two of these per event, one for X and one for Y.
# 
# **Replacements:**
# 
# `!XY!` should be either X or Y, depending on what you want to adjust.
#
# `!Val!` should be an integer value. If you're adjusting the X, negative
# values will move the image towards the left side of the screen and positive
# values will move it towards the right. If you're adjusting the Y, negative
# values will move the image towards the top of the screen and positive values
# will move it towards the bottom.
# 
# `<!Dir! Size: !Val!>`
# 
# Place this in a Comments box to adjust the size of an event. This affects
# both passability related to the event and spaces in which it can be activated.
# This is particularly useful for things like doors that are two spaces wide.
# You can have up to four of these tags per event - one for each direction.
# 
# **Replacements:**
# 
# `!Dir!` with the direction whose size you wish to alter. Possible values are
# Left, L, Right, R, Up, U, Down, and D.
# 
# `!Val!` with the number of spaces to add in the specified direction.
# 
# `<Occupies: [!X!, !Y!](, [!X!, !Y!], [!X!, !Y!],...)>`
# 
# Place this in a Comments box to specify spaces for an event to occupy. This
# affects both passability related to the event and spaces in which it can be
# activated. While the <Dir Size> tag is used to enlarge an event's
# rectangular size, the <Occupies> tag is used to allow events to have other
# shapes like triangles, circles, or octopi. Each [X, Y] pair placed in the tag
# will specify an offset - [1,1] would point to the space below and to the right
# of the event, while [-1,1] would point to the space below and to the left.
# 
# **Replacements:**
# 
# `!X!` should be the X offset for a given space. Negative values indicate
# spaces to the left of the event. Positive values indicate spaces to the right
# of the event.
# 
# `!Y!` should be the Y offset for a given space. Negative values indicate
# spaces above the event. Positive values indicate spaces below the event.
# 
# `<Condition: !Cond!(!Params!)[, !Cond!(!Params!), !Cond!(!Params!),...]>`
# 
# Place this in a Comments box to give an event page extra conditions. You can
# include as many of these as you would like on a page, though as each tag can
# contain multiple conditions it seems unlikely that you will need more than
# one. You can pass parameters to conditions by placing parentheses around them.
# Do not put spaces between passed parameters - only commas. See the Conditions
# hash in the SES::Events module for a long list of example conditions.
# 
# **Replacements:**
# 
# `!Cond!` with the name of the key in Conditions that you want to use as a
# condition.
# 
# `<EventBlock>`
# 
# Place this in a Comments box to cause an event to prevent other events from
# passing them, regardless of their priority type.
# 
# **Replacements:**
# 
# None.
# 
# `<MovementType: !Type!>`
# 
# Place this in a Comments box to change the movement type of the event page to
# that of a boat, ship, or airship.
# 
# **Replacements:**
# 
# `!Type!` with Boat, Ship, or Fly.
# 
# `<Sound: !SE!, !MV!, !MD!>`
# 
# Place this in a Comments box to cause the event to produce a Sound Effect
# when the player is near.
# 
# **Replacements:**
# 
# `!SE!` with the name of the file in Audio/BGS (without the extension).
#
# `!MV!` with the loudest the sound is allowed to be (max 100).
# 
# `!MD!` with the maximum distance that the player can be and still hear the
# sound (albeit faintly); this is also used to calculate how loud the sound is
# at various distances.
# 
# Aliased Methods
# -----------------------------------------------------------------------------
# * `class Game_Event`
#     - `update`
#     - `conditions_met?`
# 
# New Methods
# -----------------------------------------------------------------------------
# * `class Game_Event`
#     - `width`
#     - `height`
#     - `occupied_spaces`
#     - `pos?`
#     - `screen_x`
#     - `screen_y`
#     - `map_passable?`
#     - `volume`
#     - `distance_from`
#     - `passable?`
#     - `collide_with_events?`
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   This script requires the SES Core (v2.2 or higher) in order to function.
# This script may be found in the SES source repository at the following
# location:
# 
# * [Core](https://raw.github.com/sesvxace/core/master/lib/core.rb)
# 
# Place this script below Materials, but above Main. Place this script below
# the SES Core.
# 
#++
module SES module Events
  Conditions = {
    # Key => proc { script to evaluate },
    # =========================================================================
    # Variable Related
    #  These conditions can be used to set page conditions based on the value of
    # entries in the $game_variables array. Almost all of them take the same
    # three parameters, described below.
    #
    # Parameters:
    #  var - the ID of a variable in $game_variables
    #  val - the value against which the $game_variables entry is being checked
    #  gvar - omit this if you wish val to be a solid value, but if you want val
    #         to be another variable ID you can put true in this slot
    #
    # Examples:
    #  <Conditions: var_!=(1,5)>
    #   This will ensure that the page will only be displayed if the variable
    #  with ID 1 is not equal to 5.
    #
    #  <Conditions: var_==(1,2,true)>
    #   This will ensure that the page will only be displayed if the variable
    #  with ID 1 is equal to the variable with ID 2.
    # =========================================================================
    # If $game_variables[var] does not equal val
    'var_!=' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] != val
    end,
    # If $game_variables[var] equals val
    'var_==' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] == val
    end,
    # If $game_variables[var] is less than val
    'var_<' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] < val
    end,
    # If $game_variables[var] is less than or equal to val
    'var_<=' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] <= val
    end,
    # If $game_variables[var] is greater than val
    'var_>' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] > val
    end,
    # If $game_variables[var] is greater than or equal to val
    'var_>=' => proc do |var, val, gvar|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] >= val
    end,
    # If $game_variables[var] is present in the range val1..val2
    # Extra Parameters:
    #  val1 - the lower end of the range being checked
    #  val2 - the upper end of the range being checked
    #  gvar1 - same as gvar for other variable conditions, but affects only val1
    #  gvar2 - same as gvar for other variable conditions, but affects only val2
    'var_between' => proc do |var, val1, val2, gvar1, gvar2|
      lower_bound = (gvar1['true'] ? $game_variables[val1.to_i] : val1.to_i)
      upper_bound = (gvar2['true'] ? $game_variables[val2.to_i] : val2.to_i)
      (lower_bound..upper_bound).include?($game_variables[var])
    end,
    # If $game_variables[var] is not present in the range val1..val2
    # Extra Parameters:
    #  val1 - the lower end of the range being checked
    #  val2 - the upper end of the range being checked
    #  gvar1 - same as gvar for other variable conditions, but affects only val1
    #  gvar2 - same as gvar for other variable conditions, but affects only val2
    'var_not_between' => proc do |var, val1, val2, gvar1, gvar2|
      lower_bound = (gvar1['true'] ? $game_variables[val1.to_i] : val1.to_i)
      upper_bound = (gvar2['true'] ? $game_variables[val2.to_i] : val2.to_i)
      !(lower_bound..upper_bound).include?($game_variables[var])
    end,
    # =========================================================================
    # Switch Related
    #  These conditions can be used to set page conditions based on the value of
    # entries in the $game_switches array. All of them take the same parameters,
    # described below.
    #
    # Parameters:
    #  switch - the ID of a switch in $game_switches
    #  value - either true or false, depending on whether the switch should be
    #          on or off
    #
    # Examples:
    #  <Conditions: switch(1,true)>
    #   This will ensure that the page will only be displayed if the switch with
    #  ID 1 is on.
    #
    #  <Conditions: switch(1,false)>
    #   This will ensure that the page will only be displayed if the switch with
    #  ID 1 is off.
    # =========================================================================
    # If $game_switches[switch] is equal to value
    'switch' => proc do |switch, value|
      $game_switches[switch.to_i] == (value == 'true' ? true : false)
    end,
    # =========================================================================
    # Actor Related
    #  These conditions can be used to set page conditions based on values
    # related to actors. All of them have the same basic parameter, described
    # below. They also share the same final parameter, also described below.
    #
    # Parameters:
    #  actor - the ID of an actor in $game_actors
    #  party - omit this if you are specifying an actor by ID, but put true in
    #          this slot if you wish for actor to point to a slot in the party
    #          (party indicies begin at 0)
    #
    # Examples:
    #  <Conditions: actor_using_weapon(1,5)>
    #   This will ensure that the page will only be displayed if the actor with
    #  ID 1 is using the weapon with ID 5.
    #
    #  <Conditions: actor_param_>=(0,atk,100,false,true)>
    #   This will ensure that the page will only be displayed if the actor in
    #  the party's first slot has an atk stat that is greater than or equal to
    #  100.
    # =========================================================================
    # If the actor with ID actor is equipped with the weapon with ID wid
    'actor_using_weapon' => proc do |actor, wid, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.weapons.include?($data_weapons[wid.to_i])
    end,
    # If the actor with ID actor is equipped with the armor with ID aid
    'actor_using_armor' => proc do |actor, aid, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.weapons.include?($data_armors[aid.to_i])
    end,
    # If the actor with ID actor has a level greater than lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_>' => proc do |actor, lvl, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level > (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level greater than or equal to lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_>=' => proc do |actor, lvl, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level >= (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level less than lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_<' => proc do |actor, lvl, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level < (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level less than or equal to lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_<=' => proc do |actor, lvl, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level <= (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has param param at a value greater than val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_>' => proc do |actor, param, val, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) > (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value greater than or
    #  equal to val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_>=' => proc do |actor, param, val, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) >= (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value less than val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_<' => proc do |actor, param, val, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) < (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value less than or equal
    #  to val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_<=' => proc do |actor, val, gvar, party|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) <= (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # =========================================================================
    # Party Related
    #  These conditions can be used to set page conditions based on values
    # related to the party.
    #
    # Examples:
    #  <Conditions: actor_in_party(1)>
    #   This will ensure that the page will only be displayed if the actor with
    #  ID 1 is in the party.
    #
    #  <Conditions: party_has_item(1)>
    #   This will ensure that the page will only be displayed if the party has
    #  at least one of the item with ID 1 in the inventory.
    # =========================================================================
    # If the party includes the actor with ID actor
    'actor_in_party' => proc do |actor|
      $game_party.members.include?($game_actors[actor.to_i])
    end,
    # If the party does not include the actor with ID actor
    'actor_out_of_party' => proc do |actor|
      !$game_party.members.include?($game_actors[actor.to_i])
    end,
    # If the party has at least one of the item with ID item
    'party_has_item' => proc do |item|
      $game_party.has_item?($data_items[item.to_i])
    end,
    # If the party has at least one of the weapon with ID weapon
    'party_has_weapon' => proc do |weapon|
      $game_party.has_item?($data_weapons[weapon.to_i])
    end,
    # If the party has at least one of the armor with ID armor
    'party_has_armor' => proc do |armor|
      $game_party.has_item?($data_armors[armor.to_i])
    end,
  }
    
  # RegExp for an event's adjusted X or Y.
  AdjustXY = /^<Adjusted (X|Y):\s*([\-\d]+)>/i
  # RegExp for an event's adjusted size.
  EventSize = /^<(\w+) Size:\s*(\d+)>/i
  # RegExp to specify spaces as occupied by an event.
  OccupiedSpaces = /^<Occupies:\s*(.+)>/i
  # Hash of values used with the above tags. You can add new aliases for the
  # values - refer to the current settings to get an idea of what does what.
  ArrValues = { 'left' => 0, 'l' => 0, 'right' => 1, 'r' => 1,
                'up' => 2, 'u' => 2, 'down' => 3, 'd' => 3,
                'x' => 0, 'y' => 1 }
  # RegExp for an event page's extra conditions. You can include more than
  # one.
  ExtraCondition = /^<Condition:\s*((.+(\(.+\))?[,\s]*)+)>/i
  # RegExp to cause an event page to block the movement of other events.
  EventBlock = /^<(EventBlock|Event Block)>/i
  # RegExp for an event page's movement type.
  MovementType = /^<Movement:\s*(Boat|Ship|Fly)>/i
  # RegExp for the SE that will play when the player is close to the event
  PlaySound = /^<Sound:\s*(\w+),\s*(\d+),\s*(\d+)>/i
  
  # Register this script with the SES Core.
  Description = Script.new('Enhanced Events', 2.1, :Enelvon)
  Register.enter(Description)
end end

# Class for pages of an event in RPG Maker VX Ace.
class RPG::Event::Page

  alias_method :en_ee_sc, :scan_ses_comments
  # Scans Comments boxes present on an event page.
  #
  # @param tags [Hash] hash of tags that should be parsed
  def scan_ses_comments(comments = {})
    @extra_conditions = []
    @event_block = false
    @movement = 'walking'
    @sound = []
    @adjusted_xy = [0,0]
    @size = [0,0,0,0]
    @occupied_spaces = []
    comments[SES::Events::AdjustXY] =
      proc do |xy, pixels|
        @adjusted_xy[SES::Events::ArrValues[xy.downcase]] = pixels.to_i
      end
    comments[SES::Events::EventSize] =
      proc do |direction, size|
        @size[SES::Events::ArrValues[direction.downcase]] = size.to_i
      end
    comments[SES::Events::OccupiedSpaces] =
      proc do |coords|
        coords.gsub!(/(?:\(([\-\d]+)[,\s*]+([\-\d]+)\))+?/) do
          @occupied_spaces << [$1.to_i, $2.to_i]; ''
        end
      end
    comments[SES::Events::ExtraCondition] =
      proc do |condition|
        condition.split(/,\s+/).each do |condition|
          condition[/(.+)\((.+)\)/]
          @extra_conditions.push([$1, ($2.split(/,/) rescue [])])
        end
      end
    comments[SES::Events::EventBlock] =
      proc { @event_block = true }
    comments[SES::Events::MovementType] =
      proc do |type|
        @movement = type.downcase
      end
    comments[SES::Events::PlaySound] =
      proc do |se, mv, md|
        @sound = [se, mv.to_i, md.to_i]
      end
    en_ee_sc(comments)
  end

  [:extra_conditions, :event_block, :movement, :sound, :adjusted_xy,
   :size, :occupied_spaces].each do |i|
    define_method(i) do
      scan_ses_comments if instance_variable_get("@#{i}").nil?
      return instance_variable_get("@#{i}")
    end
  end
end

# Class for on-map events in RPG Maker VX Ace.
class Game_Event < Game_Character
  attr_reader :page
  
  # Obtains an array of x values occupied by the event.
  #
  # @param x [Integer] starting x value of the event
  # @return [Array] array of x values occupied by the event
  def width(x = @x)
    width = [x]
    return width unless @page
    @page.size[0].times { |i| width << x - (i + 1) }
    @page.size[1].times { |i| width << x + (i + 1) }
    return width
  end
  
  # Obtains an array of y values occupied by the event.
  #
  # @param y [Integer] starting y value of the event
  # @return [Array] array of y values occupied by the event
  def height(y = @y)
    height = [y]
    return height unless @page
    @page.size[2].times { |i| height << y - (i + 1) }
    @page.size[3].times { |i| height << y + (i + 1) }
    return height
  end
  
  # Obtains an array of spaces occupied by the event outside of a rectangular
  #  shape.
  #
  # @return [Array] array of spaces occupied by the event in the format [x, y]
  def occupied_spaces
    spaces = []
    return spaces unless @page
    @page.occupied_spaces.each do |coord|
      spaces << [@x + coord[0], @y + coord[1]]
    end
    return spaces
  end
  
  # Determines whether the event occupies a given space on the map.
  #
  # @param x [Integer] the x value of the space being checked
  # @param y [Integer] the y value of the space being checked
  # @return [TrueClass, FalseClass] whether or not the event occupies the space
  def pos?(x, y)
    (width.include?(x) && height.include?(y)) ||
    occupied_spaces.include?([x, y])
  end
  
  # Checks the x value at which the event should be drawn on the screen.
  #
  # @return [Integer] the x position at which the event should be drawn
  def screen_x
    @page ? super + @page.adjusted_xy[0] : super
  end
  
  # Checks the y value at which the event should be drawn on the screen.
  #
  # @return [Integer] the y position at which the event should be drawn
  def screen_y
    @page ? super + @page.adjusted_xy[1] : super
  end
  
  # Checks whether or not the event can move onto a given space based on the
  #  passability settings of the map.
  #
  # @param x [Integer] the x value of the space being checked
  # @param y [Integer] the y value of the space being checked
  # @param d [Integer] the direction in which the event is moving
  # @return [TrueClass, FalseClass] whether or not the event can enter the space
  def map_passable?(x, y, d)
    case @page.movement
    when 'boat'; $game_map.boat_passable?(x, y)
    when 'ship'; $game_map.ship_passable?(x, y)
    when 'flying'; true
    else super end
  end
  
  alias_method :en_ee_ge_u, :update
  # General update processing for the event.
  def update
    en_ee_ge_u
    if @sound.nil? && @page && !@page.sound.empty?
      @sound = RPG::BGS.new(@page.sound[0], volume(*@page.sound[1..2]), 100)
      @sound.play
    end
    if @sound
      @sound.volume = volume(@page.sound[1], @page.sound[2]) and @sound.play
    end
  end
  
  # Checks the volume at which the event's sound effect should be played.
  #
  # @param max_vol [Integer] the maximum volume at which the sound effect can be
  #  played
  # @param max_dist [Integer] the maximum distance at which the sound effect can
  #  be heard
  # @return [Integer] the volume at which the sound effect should be played
  def volume(max_vol, max_dist)
    if distance_from($game_player) > max_dist then 0 
    else [max_vol,
         (max_vol / max_dist) * (max_dist+1 - distance_from($game_player))].min
    end
  end
  
  # Checks how far the event is from a specified character.
  #
  # @param char [Game_Character] the character whose proximity is being checked
  # @return [Integer] the distance between the event and the character
  def distance_from(char)
    return distance_x_from(char.x).abs + distance_y_from(char.y).abs
  end
  
  # Checks if a given map tile is passable.
  #
  # @param x [Integer] the x value of the space being checked
  # @param y [Integer] the y value of the space being checked
  # @param d [Integer] the direction in which the event is moving
  # @return [TrueClass, FalseClass] whether or not the event can enter the space
  def passable?(x, y, d)
    case d
    when 2, 8
      xindex = [x].concat(width(x))
      xindex.each { |x| return false unless super(x, y, d) }
    when 4, 6
      yindex = [y].concat(height(y))
      yindex.each { |y| return false unless super(x, y, d) }
    end
    return true
  end
  
  # Checks whether or not this event should be blocked by other events on a
  #  given tile.
  #
  # @param x [Integer] the x value of the space being checked
  # @param y [Integer] the y value of the space being checked
  # @return [TrueClass, FalseClass] whether or not the event should be blocked
  def collide_with_events?(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      return true if event.page.event_block
      return false if event.through
      return event.priority_type == self.priority_type
    end
  end
  
  alias_method :en_ee_ge_cm, :conditions_met?
  # Checks whether or not a given page meets the requirements to become active.
  #
  # @param page [RPG::Event::Page] the page whose conditions are being checked
  # @return [TrueClass, FalseClass] whether or not the page should become active
  def conditions_met?(page)
    page.extra_conditions.each do |i|
      return false unless instance_exec(i[1], &SES::Events::Conditions[i[0]])
    end
    en_ee_ge_cm(page)
  end
end