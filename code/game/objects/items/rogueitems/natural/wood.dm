/obj/item/grown/log/tree
	icon = 'icons/roguetown/items/natural.dmi'
	name = "log"
	desc = "A big tree log. It's very heavy, and huge."
	icon_state = "log"
	blade_dulling = DULLING_CUT
	attacked_sound = 'sound/misc/woodhit.ogg'
	max_integrity = 30
	static_debris = list(/obj/item/grown/log/tree/small = 1)
	obj_flags = CAN_BE_HIT
	resistance_flags = FLAMMABLE
	twohands_required = TRUE
	gripped_intents = list(/datum/intent/hit)
	possible_item_intents = list(/datum/intent/hit)
	obj_flags = CAN_BE_HIT
	w_class = WEIGHT_CLASS_HUGE
	var/quality = SMELTERY_LEVEL_NORMAL // For it not to ruin recipes that need it
	var/lumber = /obj/item/grown/log/tree/small //These are solely for lumberjack calculations
	var/lumber_amount = 1

/obj/item/grown/log/tree/attacked_by(obj/item/I, mob/living/user) //This serves to reward woodcutting
	if(user.used_intent.blade_class == BCLASS_CHOP && lumber_amount)
		var/skill_level = user.mind.get_skill_level(/datum/skill/labor/lumberjacking)
		var/lumber_time = (40 - (skill_level * 5))
		var/minimum = 1
		playsound(src, 'sound/misc/woodhit.ogg', 100, TRUE)
		if(!do_after(user, lumber_time, target = user))
			return
		if(skill_level > 0) // If skill level is 1 or higher, we get more minimum wood!
			minimum = 2
		lumber_amount = rand(minimum, max(round(skill_level), minimum))
		for(var/i = 0; i < lumber_amount; i++)
			new lumber(get_turf(src))
		if(!skill_level)
			to_chat(user, span_info("My poor skill has me ruin some of the timber..."))
		user.mind.add_sleep_experience(/datum/skill/labor/lumberjacking, (user.STAINT*0.5))
		playsound(src, destroy_sound, 100, TRUE)
		qdel(src)
		return TRUE
	..()

/obj/item/grown/log/tree/small
	name = "small log"
	desc = "Smaller log that came from a larger log. Suitable for building."
	icon_state = "logsmall"
	attacked_sound = 'sound/misc/woodhit.ogg'
	max_integrity = 30
	static_debris = list(/obj/item/grown/log/tree/stick = 3)
	firefuel = 20 MINUTES
	twohands_required = FALSE
	gripped_intents = null
	w_class = WEIGHT_CLASS_BULKY
	smeltresult = /obj/item/rogueore/coal
	lumber_amount = 0

/obj/item/grown/log/tree/bowpartial
	name = "crude bowstave"
	desc = "A partially completed bow, still waiting to be strung."
	icon_state = "bowpartial"
	max_integrity = 30
	firefuel = 10 MINUTES
	twohands_required = FALSE
	gripped_intents = null
	w_class = WEIGHT_CLASS_BULKY
	smeltresult = /obj/item/rogueore/coal
	lumber_amount = 0

/obj/item/grown/log/tree/bowpartial/recurve
	name = "recurve bowstave"
	desc = "An incomplete recurve awaiting stringing."
	icon = 'icons/roguetown/items/64x.dmi'
	icon_state = "recurve_bowstave"

/obj/item/grown/log/tree/bowpartial/longbow
	name = "long bowstave"
	desc = "An incomplete longbow awaiting its string."
	icon = 'icons/roguetown/items/64x.dmi'
	icon_state = "long_bowstave"

/obj/item/grown/log/tree/stick
	name = "stick"
	icon_state = "stick1"
	desc = "A dry stick from a tree branch."
	blade_dulling = 0
	max_integrity = 20
	static_debris = null
	firefuel = 5 MINUTES
	obj_flags = null
	w_class = WEIGHT_CLASS_NORMAL
	twohands_required = FALSE
	gripped_intents = null
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP
	lumber_amount = 0

/obj/item/grown/log/tree/stick/Crossed(mob/living/L)
	. = ..()
	if(istype(L))
		var/prob2break = 33
		if(L.m_intent == MOVE_INTENT_SNEAK)
			prob2break = 0
		if(L.m_intent == MOVE_INTENT_RUN)
			prob2break = 100
		if(prob(prob2break))
			playsound(src,'sound/items/seedextract.ogg', 100, FALSE)
			qdel(src)
			if (L.alpha == 0 && L.rogue_sneaking) // not anymore you're not
				L.update_sneak_invis(TRUE)
			L.consider_ambush()

/obj/item/grown/log/tree/stick/Initialize()
	icon_state = "stick[rand(1,2)]"
	..()

/obj/item/grown/log/tree/stick/attack_self(mob/living/user)
	user.visible_message(span_warning("[user] snaps [src]."))
	playsound(user,'sound/items/seedextract.ogg', 100, FALSE)
	qdel(src)

/obj/item/grown/log/tree/stick/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.used_intent?.blade_class == BCLASS_CUT)
		playsound(get_turf(src.loc), 'sound/items/wood_sharpen.ogg', 100)
		if(do_after(user, 20))
			user.visible_message(span_notice("[user] sharpens [src]."))
			var/obj/item/grown/log/tree/stake/S = new /obj/item/grown/log/tree/stake(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(S)
			qdel(src)
		else
			user.visible_message(span_warning("[user] sharpens [src]."))
		return
	if(istype(I, /obj/item/grown/log/tree/stick))
		var/obj/item/natural/B = I
		var/obj/item/natural/bundle/stick/N = new(src.loc)
		to_chat(user, "You tie the sticks into a bundle.")
		qdel(B)
		qdel(src)
		user.put_in_hands(N)
	else if(istype(I, /obj/item/natural/bundle/stick))
		var/obj/item/natural/bundle/B = I
		if(istype(src, B.stacktype))
			if(B.amount < B.maxamount)
				B.amount++
				B.update_bundle()
				user.visible_message("[user] adds [src] to [I].")
				qdel(src)
			else
				to_chat(user, "This bundle of sticks is falling apart, at this point.")
			return

/obj/item/grown/log/tree/stake
	name = "stake"
	icon_state = "stake"
	desc = "A wooden stake, and it's pointy end!"
	force = 10
	throwforce = 5
	possible_item_intents = list(/datum/intent/stab, /datum/intent/pick)
	firefuel = 1 MINUTES
	blade_dulling = 0
	max_integrity = 20
	static_debris = null
	tool_behaviour = TOOL_IMPROVISED_RETRACTOR
	obj_flags = null
	w_class = WEIGHT_CLASS_SMALL
	twohands_required = FALSE
	gripped_intents = null
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP
	lumber_amount = 0

/obj/item/grown/log/tree/stake/silver
	name = "silver stake"
	desc = "A blessed silver stake, the bane of the unholy."
	icon_state = "silverstake"
	is_silver = TRUE
	force = 20
	throwforce = 10
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	experimental_inhand = TRUE
	anvilrepair = TRUE

/obj/item/grown/log/tree/stake/silver/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = -6,"nx" = 11,"ny" = -6,"wx" = -4,"wy" = -3,"ex" = 2,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)



/*/obj/item/grown/log/tree/lumber
	name = "lumber"
	icon_state = "lumber"
	desc = "This is some lumber." // i haven't seen this ingame yet
	blade_dulling = 0
	max_integrity = 50
	firefuel = 5 MINUTES
Removed for lumberjacking/handcart upgrade PR */
