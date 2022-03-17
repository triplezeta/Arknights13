/**
 * ## Basic Projectile spell
 *
 * Simply fires specified projectile type the direction the caster is facing.
 *
 * Behavior could / should probably be unified with pointed projectile spells
 * and aoe projectile spells in the future.
 */
/datum/action/cooldown/spell/basic_projectile
	/// How far we try to fire the basic projectile. Blocked by dense objects.
	var/projectile_range = 7
	/// The projectile type fired at all people around us
	var/obj/projectile/projectile_type = /obj/projectile/magic/spell/magic_missile

/datum/action/cooldown/spell/basic_projectile/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(user)
	for(var/i in 1 to projectile_range - 1)
		var/turf/next_turf = get_step(target_turf, cast_on.dir)
		if(next_turf.density)
			break
		target_turf = new_turf

	fire_projectile(target_turf, cast_on)

/datum/action/cooldown/spell/basic_projectile/proc/fire_projectile(atom/target, atom/cast_on)
	var/obj/projectile/to_fire = new projectile_type()
	to_fire.preparePixelProjectile(target_turf, caster)
	to_fire.fire()
