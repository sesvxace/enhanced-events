Enhanced Events v2.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script adds in some new features for events, including extra conditions
(such as script calls or requiring more than one actor to be in the party),
moving like a boat, ship, or airship, and changed passability so that events
set as Below Characters or Above Characters no longer block the movement of
events set as Same as Characters, unless they include a certain tag in a
Comments box. v2.0 adds in the ability to alter the effective size of an event
for passability and activation as well as the ability to adjust the event's
draw position.

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
  SES Core v2.2 or higher.

**Known Incompatibilities:**
 None, though it contains some redefinitions so some may occur if this script
is below another script that aliases the same method, or if it is above
another script that redefines that method. A full list of redefinitions is
included at the bottom of my comments.

Usage
-----------------------------------------------------------------------------
  This script is controlled through tags placed in comments boxes on event
pages as well as through the Conditions hash in the `SES::EnhancedEvents`
module. Instructions for the hash are detailed in the module itself, while
information about the tags is provided here.

##Event Comment Tags:

`<Adjusted !XY!: !Val!>`

Place this in a comments box to adjust the position in which an event is
drawn. You may have up to two of these per event, one for X and one for Y.

**Replacements:**

`!XY!` should be either X or Y, depending on what you want to adjust.

`!Val!` should be an integer value. If you're adjusting the X, negative
values will move the image towards the left side of the screen and positive
values will move it towards the right. If you're adjusting the Y, negative
values will move the image towards the top of the screen and positive values
will move it towards the bottom.

`<!Dir! Size: !Val!>`

Place this in a Comments box to adjust the size of an event. This affects
both passability related to the event and spaces in which it can be activated.
This is particularly useful for things like doors that are two spaces wide.
You can have up to four of these tags per event - one for each direction.

**Replacements:**

`!Dir!` with the direction whose size you wish to alter. Possible values are
Left, L, Right, R, Up, U, Down, and D.

`!Val!` with the number of spaces to add in the specified direction.

`<Occupies: [!X!, !Y!](, [!X!, !Y!], [!X!, !Y!],...)>`

Place this in a Comments box to specify spaces for an event to occupy. This
affects both passability related to the event and spaces in which it can be
activated. While the <Dir Size> tag is used to enlarge an event's
rectangular size, the <Occupies> tag is used to allow events to have other
shapes like triangles, circles, or octopi. Each [X, Y] pair placed in the tag
will specify an offset - [1,1] would point to the space below and to the right
of the event, while [-1,1] would point to the space below and to the left.

**Replacements:**

`!X!` should be the X offset for a given space. Negative values indicate
spaces to the left of the event. Positive values indicate spaces to the right
of the event.

`!Y!` should be the Y offset for a given space. Negative values indicate
spaces above the event. Positive values indicate spaces below the event.

`<Condition: !Cond!(, !Cond!, !Cond!,...)>`

Place this in a Comments box to give an event page extra conditions. You can
include as many of these as you would like on a page, though as each tag can
contain multiple conditions it seems unlikely that you will need more than
one.

**Replacements:**

`!Cond!` with the name of the key in Conditions that you want to use as a
condition.

`<EventBlock>`

Place this in a Comments box to cause an event to prevent other events from
passing them, regardless of their priority type.

**Replacements:**

None.

`<MovementType: !Type!>`

Place this in a Comments box to change the movement type of the event page to
that of a boat, ship, or airship.

**Replacements:**

`!Type!` with Boat, Ship, or Fly.

`<Sound: !SE!, !MV!, !MD!>`

Place this in a Comments box to cause the event to produce a Sound Effect
when the player is near.

**Replacements:**

`!SE!` with the name of the file in Audio/BGS (without the extension).

`!MV!` with the loudest the sound is allowed to be (max 100).

`!MD!` with the maximum distance that the player can be and still hear the
sound (albeit faintly); this is also used to calculate how loud the sound is
at various distances.

Aliased Methods
-----------------------------------------------------------------------------
* `class Game_Event`
    - `update`
    - `conditions_met?`

New Methods
-----------------------------------------------------------------------------
* `class Game_Event`
    - `width`
    - `height`
    - `occupied_spaces`
    - `pos?`
    - `screen_x`
    - `screen_y`
    - `map_passable?`
    - `volume`
    - `distance_from`
    - `passable?`
    - `collide_with_events?`

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  This script requires the SES Core (v2.2 or higher) in order to function.
This script may be found in the SES source repository at the following
location:

* [Core](https://raw.github.com/sesvxace/core/master/lib/core.rb)

Place this script below Materials, but above Main. Place this script below
the SES Core.
