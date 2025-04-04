package core.artifact {
import generics.Localize;

public class ArtifactStat {
    public static function parseTextFromStatType(type:String, value:Number, isUnique:Boolean = false):String {
        var _loc5_:String = isUnique ? "<FONT COLOR=\'#FFaa44\'>" : "<FONT COLOR=\'#D3D3D3\'>";
        var _loc6_:String = "</FONT>";
        var _loc4_:* = value > 0 ? "+" : "";
        switch (type) {
            case "healthAdd":
            case "healthAdd2":
            case "healthAdd3":
                _loc5_ += _loc4_ + (2 * value).toFixed(1) + " " + Localize.t("health") + _loc6_;
                break;
            case "healthMulti":
                _loc5_ += _loc4_ + (1.35 * value).toFixed(1) + "%" + " " + Localize.t("health") + _loc6_;
                break;
            case "armorAdd":
            case "armorAdd2":
            case "armorAdd3":
                _loc5_ += _loc4_ + (7.5 * value).toFixed(1) + " " + Localize.t("armor") + _loc6_;
                break;
            case "armorMulti":
                _loc5_ += _loc4_ + (1 * value).toFixed(1) + "%" + " " + Localize.t("armor") + _loc6_;
                break;
            case "corrosiveAdd":
            case "corrosiveAdd2":
            case "corrosiveAdd3":
                _loc5_ += _loc4_ + (4 * value).toFixed(1) + " " + Localize.t("corrosive dmg") + _loc6_;
                break;
            case "corrosiveMulti":
                _loc5_ += _loc4_ + (1 * value).toFixed(1) + "%" + " " + Localize.t("corrosive dmg") + _loc6_;
                break;
            case "energyAdd":
            case "energyAdd2":
            case "energyAdd3":
                _loc5_ += _loc4_ + (4 * value).toFixed(1) + " " + Localize.t("energy dmg") + _loc6_;
                break;
            case "energyMulti":
                _loc5_ += _loc4_ + (1 * value).toFixed(1) + "%" + " " + Localize.t("energy dmg") + _loc6_;
                break;
            case "kineticAdd":
            case "kineticAdd2":
            case "kineticAdd3":
                _loc5_ += _loc4_ + (4 * value).toFixed(1) + " " + Localize.t("kinetic dmg") + _loc6_;
                break;
            case "kineticMulti":
                _loc5_ += _loc4_ + (1 * value).toFixed(1) + "%" + " " + Localize.t("kinetic dmg") + _loc6_;
                break;
            case "shieldAdd":
            case "shieldAdd2":
            case "shieldAdd3":
                _loc5_ += _loc4_ + (1.75 * value).toFixed(1) + " " + Localize.t("shield") + _loc6_;
                break;
            case "shieldMulti":
                _loc5_ += _loc4_ + (1.35 * value).toFixed(1) + "%" + " " + Localize.t("shield") + _loc6_;
                break;
            case "shieldRegen":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + " " + Localize.t("shield regen") + _loc6_;
                break;
            case "corrosiveResist":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + " " + Localize.t("corrosive resist") + _loc6_;
                break;
            case "energyResist":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + " " + Localize.t("energy resist") + _loc6_;
                break;
            case "kineticResist":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + " " + Localize.t("kinetic resist") + _loc6_;
                break;
            case "allResist":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + " " + Localize.t("all resist") + _loc6_;
                break;
            case "allAdd":
            case "allAdd2":
            case "allAdd3":
                _loc5_ += _loc4_ + (1.5 * value).toFixed(1) + " " + Localize.t("to all dmg") + _loc6_;
                break;
            case "allMulti":
                _loc5_ += _loc4_ + (1.5 * value).toFixed(1) + "%" + " " + Localize.t("to all dmg") + _loc6_;
                break;
            case "dotDamage":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" damage on all debuffs.") + _loc6_;
                break;
            case "dotDuration":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" duration on all debuffs.") + _loc6_;
                break;
            case "directDamage":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" direct damage.") + _loc6_;
                break;
            case "speed":
            case "speed2":
            case "speed3":
                _loc5_ += _loc4_ + (0.1 * 2 * value).toFixed(2) + "%" + " " + Localize.t("inc speed") + _loc6_;
                break;
            case "refire":
            case "refire2":
            case "refire3":
                _loc5_ += _loc4_ + (3 * 0.1 * value).toFixed(1) + "%" + " " + Localize.t("inc attack speed") + _loc6_;
                break;
            case "convHp":
                if (0.1 * value > 100) {
                    _loc5_ += "-100% " + Localize.t("hp to 150% shield") + _loc6_;
                } else {
                    _loc5_ += "-" + (0.1 * value).toFixed(1) + "%" + " " + Localize.t("hp to 150% shield") + _loc6_;
                }
                break;
            case "convShield":
                if (0.1 * value > 100) {
                    _loc5_ += "-100% " + Localize.t("shield to 150% hp") + _loc6_;
                } else {
                    _loc5_ += "-" + (0.1 * value).toFixed(1) + "%" + " " + Localize.t("shield to 150% hp") + _loc6_;
                }
                break;
            case "powerReg":
            case "powerReg2":
            case "powerReg3":
                _loc5_ += _loc4_ + (0.1 * 1.5 * value).toFixed(1) + "%" + " " + Localize.t("inc power regen") + _loc6_;
                break;
            case "powerMax":
                _loc5_ += _loc4_ + (1.5 * value).toFixed(1) + "%" + " " + Localize.t("inc maximum power") + _loc6_;
                break;
            case "cooldown":
            case "cooldown2":
            case "cooldown3":
                _loc5_ += _loc4_ + (0.1 * 1 * value).toFixed(1) + "% " + Localize.t("reduced cooldown") + _loc6_;
                break;
            case "increaseRecyleRate":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" increased yield from recycling junk") + _loc6_;
                break;
            case "damageReduction":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" damage reduction") + _loc6_;
                break;
            case "damageReductionWithLowHealth":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" damage reduction with low health") + _loc6_;
                break;
            case "damageReductionWithLowShield":
                _loc5_ += _loc4_ + value.toFixed(1) + "%" + Localize.t(" damage reduction with low shield") + _loc6_;
                break;
            case "healthRegenAdd":
                _loc5_ += _loc4_ + value.toFixed(1) + Localize.t("% of maximum health regenerated every second") + _loc6_;
                break;
            case "shieldVamp":
                _loc5_ += Localize.t("Steals [value]% of damage done to enemy shields.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "healthVamp":
                _loc5_ += Localize.t("Steals [value]% of damage done to enemy health.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "kineticChanceToPenetrateShield":
                _loc5_ += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to penetrate shield and deal <FONT COLOR=\'#ffccaa\'>25%</FONT> of total kinetic dmg to hull.").replace("[chance]", (0.1 * value).toFixed(1)) + _loc6_;
                break;
            case "energyChanceToShieldOverload":
                _loc5_ += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to overload shield and deal <FONT COLOR=\'#ffccaa\'>50%</FONT> more energy damage.").replace("[chance]", (0.1 * value).toFixed(1)) + _loc6_;
                break;
            case "corrosiveChanceToIgnite":
                _loc5_ += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to splice the hull and deal <FONT COLOR=\'#ffccaa\'>50%</FONT> more corrosive damage.").replace("[chance]", (0.1 * value).toFixed(1)) + _loc6_;
                break;
            case "beamAndMissileDoesBonusDamage":
                _loc5_ += Localize.t("• All Beam and Missile weapons do <FONT COLOR=\'#ffccaa\'>+[dmg]%</FONT> bonus damage.").replace("[dmg]", value.toFixed(1)) + _loc6_;
                break;
            case "recycleCatalyst":
                _loc5_ += Localize.t("• Increased the chance of finding rare material when recycling junk by <FONT COLOR=\'#ffccaa\'>50%</FONT> and increase yield with <FONT COLOR=\'#ffccaa\'>[rate]%</FONT>.").replace("[rate]", value.toFixed(1)) + _loc6_;
                break;
            case "velocityCore":
                _loc5_ += Localize.t("• Hyper-increases engine speed by <FONT COLOR=\'#ffccaa\'>[speed]%</FONT>.").replace("[speed]", (value * 2 * 0.1).toFixed(1)) + _loc6_;
                break;
            case "slowDown":
                _loc5_ += Localize.t("• Debuff: Temporarily slows down the enemy\'s speed by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> for <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]", value.toFixed(0)) + _loc6_;
                break;
            case "damageReductionUnique":
                _loc5_ += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction.") + _loc6_;
                break;
            case "damageReductionWithLowHealthUnique":
                _loc5_ += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction with low health.") + _loc6_;
                break;
            case "damageReductionWithLowShieldUnique":
                _loc5_ += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction with low shield.") + _loc6_;
                break;
            case "damageReductionWhileStationaryUnique":
                _loc5_ += "• Fortress Lock: <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction while stationary.") + _loc6_;
                break;
            case "overmind":
                _loc5_ += Localize.t("• Doubles number of pets and increase hp with <FONT COLOR=\'#ffccaa\'>50%</FONT>.") + _loc6_;
                break;
            case "upgrade":
                _loc5_ += Localize.t("• Greatly improves all ships with legacy hull, shield and armor.") + _loc6_;
                break;
            case "lucaniteCore":
                _loc5_ += Localize.t("• Debuff: Reduces targets damage by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "mantisCore":
                _loc5_ += Localize.t("• <FONT COLOR=\'#ffccaa\'>+[value]%</FONT> damage if target is close.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "thermofangCore":
                _loc5_ += Localize.t("• <FONT COLOR=\'#ffccaa\'>+[value]%</FONT> kinetic damage on burning.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "reduceKineticResistance":
                _loc5_ += Localize.t("• Debuff: Reduces targets kinetic resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "reduceCorrosiveResistance":
                _loc5_ += Localize.t("• Debuff: Reduces targets corrosive resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "reduceEnergyResistance":
                _loc5_ += Localize.t("• Debuff: Reduces targets energy resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "crownOfXhersix":
                _loc5_ += Localize.t("• Emperor\'s Will: Automatically cleanse a debuff every <FONT COLOR=\'#ffccaa\'>[value]</FONT> seconds.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "veilOfYhgvis":
                _loc5_ += Localize.t("• <FONT COLOR=\'#ffccaa\'>50%</FONT> damage reduction while cloaked and <FONT COLOR=\'#ffccaa\'>[value]%</FONT> damage bonus on ambush.").replace("[value]", 100) + _loc6_;
                break;
            case "fistOfZharix":
                _loc5_ += Localize.t("• On Kill: Activates a shockwave on kill, damaging nearby enemies with <FONT COLOR=\'#ffccaa\'>[value]%</FONT> of total shield and health.").replace("[value]", value.toFixed(1)) + _loc6_;
                break;
            case "bloodlineSurge":
                _loc5_ += Localize.t("• On Kill: Gain <FONT COLOR=\'#ffccaa\'>+[value]%</FONT> total damage, and <FONT COLOR=\'#ffccaa\'>+[value2]%</FONT> reduced damage for <FONT COLOR=\'#ffccaa\'>6</FONT> seconds, stack up to <FONT COLOR=\'#ffccaa\'>3</FONT> times.").replace("[value]", value.toFixed(1)).replace("[value2]", (value * 0.5).toFixed(1)) + _loc6_;
                break;
            case "dotDamageUnique":
                _loc5_ += "• <FONT COLOR=\'#ffccaa\'>+" + value.toFixed(1) + "%" + Localize.t("</FONT> damage on all debuffs.") + _loc6_;
                break;
            case "directDamageUnique":
                _loc5_ += "• <FONT COLOR=\'#ffccaa\'>+" + value.toFixed(1) + "%" + Localize.t("</FONT> direct damage.") + _loc6_;
                break;
            case "reflectDamageUnique":
                _loc5_ += "• If Hit: Reflects <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + Localize.t("</FONT> damage to attacker.") + _loc6_;
                break;
            default:
                _loc5_ += "ERROR, did not found artifact stat: " + type;
        }
        return _loc5_ + _loc6_;
    }

    public static function parseTextFromStatTypeShort(type:String, value:Number):String {
        var _loc3_:String = "+";
        if (value < 0) {
            _loc3_ = "";
        }
        switch (type) {
            case "healthAdd":
            case "healthAdd2":
            case "healthAdd3":
                break;
            case "healthMulti":
                return _loc3_ + (1.35 * value).toFixed(1) + "% " + Localize.t("health");
            case "armorAdd":
            case "armorAdd2":
            case "armorAdd3":
                return _loc3_ + (7.5 * value).toFixed(0) + " " + Localize.t("armor");
            case "armorMulti":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("armor");
            case "corrosiveAdd":
            case "corrosiveAdd2":
            case "corrosiveAdd3":
                return _loc3_ + (4 * value).toFixed(0) + " " + Localize.t("corrosive dmg");
            case "corrosiveMulti":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("corrosive dmg");
            case "energyAdd":
            case "energyAdd2":
            case "energyAdd3":
                return _loc3_ + (4 * value).toFixed(0) + " " + Localize.t("energy dmg");
            case "energyMulti":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("energy dmg");
            case "kineticAdd":
            case "kineticAdd2":
            case "kineticAdd3":
                return _loc3_ + (4 * value).toFixed(0) + " " + Localize.t("kinetic dmg");
            case "kineticMulti":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("kinetic dmg");
            case "shieldAdd":
            case "shieldAdd2":
            case "shieldAdd3":
                return _loc3_ + (1.75 * value).toFixed(0) + " " + Localize.t("shield");
            case "shieldMulti":
                return _loc3_ + (1.35 * value).toFixed(1) + "% " + Localize.t("shield");
            case "shieldRegen":
                return _loc3_ + value.toFixed(0) + "% " + Localize.t("shield regen");
            case "corrosiveResist":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("corrosive resist");
            case "energyResist":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("energy resist");
            case "kineticResist":
                return value.toFixed(1) + "% " + Localize.t("kinetic resist");
            case "allResist":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("all resist");
            case "allAdd":
            case "allAdd2":
            case "allAdd3":
                return _loc3_ + (1.5 * value).toFixed(1) + " " + Localize.t("to all dmg");
            case "allMulti":
                return _loc3_ + (1.5 * value).toFixed(1) + "% " + Localize.t("to all dmg");
            case "speed":
            case "speed2":
            case "speed3":
                return _loc3_ + (0.1 * value).toFixed(2) + "% " + Localize.t("speed");
            case "refire":
            case "refire2":
            case "refire3":
                return _loc3_ + (3 * 0.1 * value).toFixed(1) + "% " + Localize.t("attack speed");
            case "convHp":
                if (0.1 * value > 100) {
                    return "-100% " + Localize.t("hp to 150% shield");
                }
                return _loc3_ + (0.1 * value).toFixed(1) + "% " + Localize.t("hp to 150% shield");
                break;
            case "convShield":
                if (0.1 * value > 100) {
                    return "-100% " + Localize.t("shield to 150% hp");
                }
                return _loc3_ + (0.1 * value).toFixed(1) + "% " + Localize.t("shield to 150% hp");
                break;
            case "powerReg":
            case "powerReg2":
            case "powerReg3":
                return _loc3_ + (0.1 * value).toFixed(1) + "% " + Localize.t("power regen");
            case "powerMax":
                return _loc3_ + value.toFixed(1) + "% " + Localize.t("max power");
            case "cooldown":
            case "cooldown2":
            case "cooldown3":
                return "-" + (0.1 * value * 1).toFixed(1) + "% " + Localize.t("cooldown");
            case "increaseRecyleRate":
                return "+" + value.toFixed(1) + "%" + Localize.t(" increased yield from recycling junk.");
            default:
                return "ERROR - artifact stat not found: " + type;
        }
        return _loc3_ + (2 * value).toFixed(0) + " " + Localize.t("health");
    }

    public static function isUnique(type:String):Boolean {
        switch (type) {
            case "slowDown":
            case "kineticChanceToPenetrateShield":
            case "energyChanceToShieldOverload":
            case "corrosiveChanceToIgnite":
            case "recycleCatalyst":
            case "beamAndMissileDoesBonusDamage":
            case "velocityCore":
            case "damageReductionUnique":
            case "damageReductionWithLowShieldUnique":
            case "damageReductionWithLowHealthUnique":
            case "damageReductionWhileStationaryUnique":
            case "overmind":
            case "upgrade":
            case "lucaniteCore":
            case "mantisCore":
            case "thermofangCore":
            case "reduceKineticResistance":
            case "reduceCorrosiveResistance":
            case "reduceEnergyResistance":
            case "crownOfXhersix":
            case "veilOfYhgvis":
            case "fistOfZharix":
            case "bloodlineSurge":
            case "dotDamageUnique":
            case "directDamageUnique":
            case "reflectDamageUnique":
                break;
            default:
                return false;
        }
        return true;
    }

    public function ArtifactStat(type:String, value:Number) {
        super();
        this.type = type;
        this.value = value;
    }
    public var type:String;
    public var value:Number;

    public function get isUnique():Boolean {
        return ArtifactStat.isUnique(type);
    }
}
}

