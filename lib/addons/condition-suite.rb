#--
# Enhanced Events Condition Suite v1.0 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script extends SES Enhanced Events by providing a large number of
# sample conditions for use with the `<Condition>` tag. They are all usable
# as-is and provide examples that will hopefully be useful when it comes to
# creating your own conditions.
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
#   SES Enhanced Events v2.2 or higher.
# 
# **Known Incompatibilities:**
#  None. There will never be any - this simply modifies a hash in SES::Events.
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
# Place this script below Materials, but above Main. Place this script below
# SES Enhanced Events.
# 
#++
module SES module Events
  Conditions.merge!({
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
    'var_!=' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] != val
    end,
    # If $game_variables[var] equals val
    'var_==' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] == val
    end,
    # If $game_variables[var] is less than val
    'var_<' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] < val
    end,
    # If $game_variables[var] is less than or equal to val
    'var_<=' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] <= val
    end,
    # If $game_variables[var] is greater than val
    'var_>' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] > val
    end,
    # If $game_variables[var] is greater than or equal to val
    'var_>=' => proc do |var, val, gvar='false'|
      val = (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
      $game_variables[var.to_i] >= val
    end,
    # If $game_variables[var] is present in the range val1..val2
    # Extra Parameters:
    #  val1 - the lower end of the range being checked
    #  val2 - the upper end of the range being checked
    #  gvar1 - same as gvar for other variable conditions, but affects only val1
    #  gvar2 - same as gvar for other variable conditions, but affects only val2
    'var_between' => proc do |var, val1, val2, gvar1='false', gvar2='false'|
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
    'var_not_between' => proc do |var, val1, val2, gvar1='false', gvar2='false'|
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
    'actor_using_weapon' => proc do |actor, wid, party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.weapons.include?($data_weapons[wid.to_i])
    end,
    # If the actor with ID actor is equipped with the armor with ID aid
    'actor_using_armor' => proc do |actor, aid, party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.weapons.include?($data_armors[aid.to_i])
    end,
    # If the actor with ID actor has a level greater than lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_>' => proc do |actor, lvl, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level > (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level greater than or equal to lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_>=' => proc do |actor, lvl, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level >= (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level less than lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_<' => proc do |actor, lvl, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level < (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has a level less than or equal to lvl
    # Extra Parameters:
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_level_<=' => proc do |actor, lvl, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.level <= (gvar['true'] ? $game_variables[lvl.to_i] : lvl.to_i)
    end,
    # If the actor with ID actor has param param at a value greater than val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_>' => proc do |actor, param, val, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) > (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value greater than or
    #  equal to val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_>=' => proc do |actor, param, val, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) >= (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value less than val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_<' => proc do |actor, param, val, gvar='false', party='false'|
      actor = party['true'] ? $game_party.members[actor.to_i] : actor.to_i
      actor.send(param) < (gvar['true'] ? $game_variables[val.to_i] : val.to_i)
    end,
    # If the actor with ID actor has param param at a value less than or equal
    #  to val
    # Extra Parameters:
    #  param - any parameter name - must be lower-case
    #  gvar - same as for Variable Related Conditions - set to false if you wish
    #         to use party but not gvar
    'actor_param_<=' => proc do |actor, val, gvar='false', party='false'|
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
  })
end end