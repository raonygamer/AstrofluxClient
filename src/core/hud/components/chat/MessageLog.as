package core.hud.components.chat
{
	import com.adobe.utils.StringUtil;
	import core.hud.components.ImageButton;
	import core.player.Player;
	import core.scene.Game;
	import core.scene.SceneBase;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MessageLog extends DisplayObjectContainer
	{
		private static var g:Game;
		public static var extendedMaxLines:int = 60;
		public static var textQueue:Vector.<Object> = new Vector.<Object>();
		private static var profanities:Object = {
			"4r5e":1,
			"5h1t":1,
			"5hit":1,
			"a55":1,
			"anal":1,
			"anus":1,
			"ar5e":1,
			"arrse":1,
			"arse":1,
			"ass-fucker":1,
			"asses":1,
			"assfucker":1,
			"assfukka":1,
			"asshole":1,
			"assholes":1,
			"asswhole":1,
			"a_s_s":1,
			"b!tch":1,
			"b00bs":1,
			"b17ch":1,
			"b1tch":1,
			"ballbag":1,
			"ballsack":1,
			"bastard":1,
			"beastial":1,
			"beastiality":1,
			"bellend":1,
			"bestial":1,
			"bestiality":1,
			"biatch":1,
			"bitch":1,
			"bitcher":1,
			"bitchers":1,
			"bitches":1,
			"bitchin":1,
			"bitching":1,
			"blow job":1,
			"blowjob":1,
			"blowjobs":1,
			"boiolas":1,
			"bollock":1,
			"bollok":1,
			"boner":1,
			"boob":1,
			"boobs":1,
			"booobs":1,
			"boooobs":1,
			"booooobs":1,
			"booooooobs":1,
			"breasts":1,
			"buceta":1,
			"bunny fucker":1,
			"butthole":1,
			"buttmuch":1,
			"buttplug":1,
			"c0ck":1,
			"c0cksucker":1,
			"carpet muncher":1,
			"cawk":1,
			"chink":1,
			"cipa ":1,
			"cl1t":1,
			"clit":1,
			"clitoris":1,
			"clits":1,
			"cnut":1,
			"cock":1,
			"cock-sucker":1,
			"cockface":1,
			"cockhead":1,
			"cockmunch":1,
			"cockmuncher":1,
			"cocks":1,
			"cocksuck ":1,
			"cocksucked ":1,
			"cocksucker":1,
			"cocksucking":1,
			"cocksucks ":1,
			"cocksuka":1,
			"cocksukka":1,
			"cokmuncher":1,
			"coksucka":1,
			"cox":1,
			" cum ":1,
			"cummer":1,
			"cumming":1,
			"cums":1,
			"cumshot":1,
			"cunilingus":1,
			"cunillingus":1,
			"cunnilingus":1,
			"cunt":1,
			"cuntlick ":1,
			"cuntlicker ":1,
			"cuntlicking ":1,
			"cunts":1,
			"cyalis":1,
			"cyberfuc":1,
			"cyberfuck ":1,
			"cyberfucked ":1,
			"cyberfucker":1,
			"cyberfuckers":1,
			"cyberfucking ":1,
			"d1ck":1,
			"dick":1,
			"dickhead":1,
			"dildo":1,
			"dildos":1,
			"dink":1,
			"dinks":1,
			"dirsa":1,
			"dlck":1,
			"dog-fucker":1,
			"doggin":1,
			"dogging":1,
			"donkeyribber":1,
			"dyke":1,
			"ejaculate":1,
			"ejaculated":1,
			"ejaculates ":1,
			"ejaculating ":1,
			"ejaculatings":1,
			"ejaculation":1,
			"ejakulate":1,
			"f u c k":1,
			"f u c k e r":1,
			"f4nny":1,
			"fag":1,
			"fagging":1,
			"faggitt":1,
			"faggot":1,
			"faggs":1,
			"fagot":1,
			"fagots":1,
			"fags":1,
			"fanny":1,
			"fannyflaps":1,
			"fannyfucker":1,
			"fanyy":1,
			"fatass":1,
			"fcuk":1,
			"fcuker":1,
			"fcuking":1,
			"feck":1,
			"fecker":1,
			"felching":1,
			"fellate":1,
			"fellatio":1,
			"fingerfuck ":1,
			"fingerfucked ":1,
			"fingerfucker ":1,
			"fingerfuckers":1,
			"fingerfucking ":1,
			"fingerfucks ":1,
			"fistfuck":1,
			"fistfucked ":1,
			"fistfucker ":1,
			"fistfuckers ":1,
			"fistfucking ":1,
			"fistfuckings ":1,
			"fistfucks ":1,
			"flange":1,
			"fook":1,
			"fooker":1,
			" fu ":1,
			" f u ":1,
			"fuck":1,
			"fwck":1,
			"fvck":1,
			"fucka":1,
			"fucked":1,
			"fucker":1,
			"fuckers":1,
			"fuckhead":1,
			"fuckheads":1,
			"fuckin":1,
			"fucking":1,
			"fuckings":1,
			"fuckingshitmotherfucker":1,
			"fuckme ":1,
			"fucks":1,
			"fuckwhit":1,
			"fuckwit":1,
			"fudgepacker":1,
			"fuk":1,
			"fuker":1,
			"fukker":1,
			"fukkin":1,
			"fuks":1,
			"fukwhit":1,
			"fukwit":1,
			"fux":1,
			"fux0r":1,
			"f_u_c_k":1,
			"gangbang":1,
			"gangbanged ":1,
			"gangbangs ":1,
			"gaylord":1,
			"gaysex":1,
			"goatse":1,
			"hardcoresex ":1,
			"heshe":1,
			"hoar":1,
			"hoare":1,
			"hoer":1,
			"homo":1,
			"hore":1,
			"horniest":1,
			"horny":1,
			"hotsex":1,
			"jack-off ":1,
			"jackoff":1,
			"jerk-off ":1,
			"jism":1,
			"jiz ":1,
			"jizm ":1,
			"jizz":1,
			"kawk":1,
			"knob":1,
			"knobead":1,
			"knobed":1,
			"knobend":1,
			"knobhead":1,
			"knobjocky":1,
			"knobjokey":1,
			"kock":1,
			"kondum":1,
			"kondums":1,
			"kummer":1,
			"kumming":1,
			"kums":1,
			"kunilingus":1,
			"l3i+ch":1,
			"l3itch":1,
			"labia":1,
			"lmfao":1,
			"m0f0":1,
			"m0fo":1,
			"m45terbate":1,
			"ma5terb8":1,
			"ma5terbate":1,
			"masochist":1,
			"master-bate":1,
			"masterb8":1,
			"masterbat*":1,
			"masterbat3":1,
			"masterbate":1,
			"masterbation":1,
			"masterbations":1,
			"masturbate":1,
			"mo-fo":1,
			"mof0":1,
			"mofo":1,
			"mothafuck":1,
			"mothafucka":1,
			"mothafuckas":1,
			"mothafuckaz":1,
			"mothafucked ":1,
			"mothafucker":1,
			"mothafuckers":1,
			"mothafuckin":1,
			"mothafucking ":1,
			"mothafuckings":1,
			"mothafucks":1,
			"mother fucker":1,
			"motherfuck":1,
			"motherfucked":1,
			"motherfucker":1,
			"motherfuckers":1,
			"motherfuckin":1,
			"motherfucking":1,
			"motherfuckings":1,
			"motherfuckka":1,
			"motherfucks":1,
			"muff":1,
			"mutha":1,
			"muthafecker":1,
			"muthafuckker":1,
			"muther":1,
			"mutherfucker":1,
			"n1gga":1,
			"n1gger":1,
			"nazi":1,
			"nigg3r":1,
			"nigg4h":1,
			"nigga":1,
			"niggah":1,
			"niggas":1,
			"niggaz":1,
			"nigger":1,
			"niggers ":1,
			"nob jokey":1,
			"nobhead":1,
			"nobjocky":1,
			"nobjokey":1,
			"numbnuts":1,
			"nutsack":1,
			"orgasim ":1,
			"orgasims ":1,
			"orgasm":1,
			"orgasms ":1,
			"p0rn":1,
			"pecker":1,
			"penis":1,
			"penisfucker":1,
			"phonesex":1,
			"phuck":1,
			"phuk":1,
			"phuked":1,
			"phuking":1,
			"phukked":1,
			"phukking":1,
			"phuks":1,
			"phuq":1,
			"pigfucker":1,
			"pimpis":1,
			"piss":1,
			"pissed":1,
			"pisser":1,
			"pissers":1,
			"pisses ":1,
			"pissflaps":1,
			"pissin ":1,
			"pissing":1,
			"pissoff ":1,
			"poop":1,
			"porn":1,
			"porno":1,
			"pornography":1,
			"pornos":1,
			"pricks ":1,
			"pron":1,
			"pusse":1,
			"pussi":1,
			"pussies":1,
			"pussy":1,
			"pussys ":1,
			"rape":1,
			"rectum":1,
			"retard":1,
			"rimjaw":1,
			"rimming":1,
			"sadist":1,
			"schlong":1,
			"screwing":1,
			"scroat":1,
			"scrote":1,
			"scrotum":1,
			"semen":1,
			"sh!t":1,
			"sh1t":1,
			"shag":1,
			"shagger":1,
			"shaggin":1,
			"shagging":1,
			"shemale":1,
			"shit":1,
			"shitdick":1,
			"shite":1,
			"shited":1,
			"shitey":1,
			"shitfuck":1,
			"shitfull":1,
			"shithead":1,
			"shiting":1,
			"shitings":1,
			"shits":1,
			"shitted":1,
			"shitter":1,
			"shitters ":1,
			"shitting":1,
			"shittings":1,
			"shitty ":1,
			"skank":1,
			"slut":1,
			"sluts":1,
			"smegma":1,
			"smut":1,
			"snatch":1,
			"son-of-a-bitch":1,
			"spunk":1,
			"s_h_i_t":1,
			"t1tt1e5":1,
			"t1tties":1,
			"teets":1,
			"teez":1,
			"testical":1,
			"testicle":1,
			"titfuck":1,
			"tits":1,
			"titt":1,
			"tittie5":1,
			"tittiefucker":1,
			"titties":1,
			"tittyfuck":1,
			"tittywank":1,
			"titwank":1,
			"tosser":1,
			"tw4t":1,
			"twat":1,
			"twathead":1,
			"twatty":1,
			"twunt":1,
			"twunter":1,
			"v14gra":1,
			"v1gra":1,
			"vagina":1,
			"viagra":1,
			"vulva":1,
			"w00se":1,
			"wang":1,
			"wank":1,
			"wanker":1,
			"wanky":1,
			"whoar":1,
			"whore":1,
			"willies":1,
			"willy":1,
			"xrated":1,
			"xxx":1
		};
		public var nextTimeout:Number = 0;
		private var textureManager:ITextureManager;
		private var activeView:String;
		private var simple:ChatSimple;
		private var advanced:ChatAdvanced;
		
		public function MessageLog(g:Game)
		{
			var txt:Texture;
			var txt2:Texture;
			var toggleAdvanced:ImageButton;
			textureManager = TextureLocator.getService();
			super();
			MessageLog.g = g;
			nextTimeout = 0;
			simple = new ChatSimple(g);
			addChild(simple);
			advanced = new ChatAdvanced(g);
			simple.y = advanced.y = 20;
			addEventListener("enterFrame",update);
			txt = textureManager.getTextureGUIByTextureName("button_chat_down");
			txt2 = textureManager.getTextureGUIByTextureName("button_chat_up");
			toggleAdvanced = new ImageButton(function():void
			{
				toggleView("advanced");
			},txt,null,null,txt2);
			addChild(toggleAdvanced);
		}
		
		public static function writeSysInfo(t:String) : void
		{
			write(t);
		}
		
		public static function writeChatMsg(msgType:String, msg:String, playerKey:String = null, playerName:String = null, rights:String = "", supporter:Boolean = false) : void
		{
			var _loc7_:Object = null;
			var _loc10_:Player = null;
			var _loc15_:String = null;
			var _loc9_:int = 0;
			var _loc8_:RegExp = null;
			if(g == null)
			{
				return;
			}
			if(msg.length > 250)
			{
				_loc7_ = {};
				_loc7_.length = msg.length;
				_loc7_.msg = msg;
				g.client.errorLog.writeError("Very long chat message, over 1000 chars: ","","",_loc7_);
				return;
			}
			if(g.solarSystem.type == "pvp dom" && msgType == "local")
			{
				_loc10_ = g.playerManager.playersById[playerKey];
				if(g.me != null && _loc10_ != null && _loc10_.team != -1 && g.me.team != -1)
				{
					if(_loc10_.team != g.me.team)
					{
						return;
					}
					msgType = "team";
				}
			}
			for(var _loc12_ in profanities)
			{
				_loc15_ = "";
				_loc9_ = 0;
				while(_loc9_ < _loc12_.length)
				{
					_loc15_ += "*";
					_loc9_++;
				}
				_loc8_ = new RegExp(_loc12_,"gi");
				msg = msg.replace(_loc8_,_loc15_);
			}
			var _loc13_:String = colorCoding("[" + msgType + "]");
			var _loc14_:* = msg;
			if(playerName)
			{
				_loc14_ = playerName + ": " + _loc14_;
			}
			if(supporter)
			{
				_loc14_ = "<font color=\'#ffff66\'>&#9733;</font>" + _loc14_;
			}
			_loc14_ = colorRights(rights,_loc14_);
			var _loc11_:Object = {};
			_loc11_.type = msgType;
			_loc11_.text = StringUtil.trim(_loc13_ + " " + _loc14_);
			_loc11_.timeout = g.time + 60 * 1000;
			_loc11_.playerKey = playerKey;
			_loc11_.playerName = playerName;
			_loc11_.supporter = supporter;
			textQueue.push(_loc11_);
			if(textQueue.length > extendedMaxLines)
			{
				textQueue.splice(0,1);
			}
			g.messageLog.updateTexts(_loc11_);
		}
		
		public static function write(t:String, msgType:String = "system") : void
		{
			var _loc3_:Object = null;
			t = colorCoding(t);
			if(g != null)
			{
				_loc3_ = {};
				_loc3_.text = t;
				_loc3_.type = msgType;
				_loc3_.timeout = g.time + 60 * 1000;
				textQueue.push(_loc3_);
				if(textQueue.length > extendedMaxLines)
				{
					textQueue.splice(0,1);
				}
				g.messageLog.updateTexts(_loc3_);
			}
		}
		
		public static function colorCoding(t:String) : String
		{
			t = t.replace("[private]","<FONT COLOR=\'#9a9a9a\'>[private]</FONT>");
			t = t.replace("[debug]","<FONT COLOR=\'#9a9a9a\'>[debug]</FONT>");
			t = t.replace("[global]","<FONT COLOR=\'#cccc44\'>[global]</FONT>");
			t = t.replace("[local]","<FONT COLOR=\'#8888cc\'>[local]</FONT>");
			t = t.replace("[team]","<FONT COLOR=\'#6666ff\'>[team]</FONT>");
			t = t.replace("[clan]","<FONT COLOR=\'#88cc88\'>[clan]</FONT>");
			t = t.replace("[group]","<FONT COLOR=\'#20ecea\'>[group]</FONT>");
			t = t.replace("[mod]","<FONT COLOR=\'#ff3daf\'>[mod]</FONT>");
			t = t.replace("[modchat]","<FONT COLOR=\'#ff6daf\'>[modchat]</FONT>");
			t = t.replace("[planet wars]","<FONT COLOR=\'#ff44ff\'>[planet wars]</FONT>");
			t = t.replace("[error]","<FONT COLOR=\'#C5403A\'>[error]</FONT>");
			t = t.replace("[death]","");
			t = t.replace("[loot]","");
			return t.replace("[join_leave]","");
		}
		
		public static function colorRights(rights:String, t:String) : String
		{
			if(rights == "mod")
			{
				return "<FONT COLOR=\'#ffaa44\'>[mod]</FONT> " + t;
			}
			if(rights == "dev")
			{
				return "<FONT COLOR=\'#ff86fb\'>[dev]</FONT> " + t;
			}
			return t;
		}
		
		public static function writeDeathNote(player:Player, killerName:String, mod:String) : void
		{
			var _loc5_:String = "<FONT COLOR=\'#ff4444\'>";
			if(killerName != "")
			{
				switch(mod)
				{
					case "sun":
						_loc5_ += player.name + " flew into the sun.";
						break;
					case "comet":
						_loc5_ += player.name + " was crushed by a comet.";
						break;
					case "suicide":
						_loc5_ += player.name + " commited suicide.";
						break;
					case "Kamikaze":
						_loc5_ += killerName + " took " + player.name + " down with it.";
						break;
					case "Missile Launcher":
						_loc5_ += player.name + " was hunted down by " + killerName + "s missiles.";
						break;
					case "Mine Launcher":
						_loc5_ += player.name + " didn\'t see " + killerName + "s mines.";
						break;
					case "Plasma Gun":
						_loc5_ += player.name + " was melted by " + killerName + "s plasma.";
						break;
					case "Lightning Gun":
						_loc5_ += player.name + " was electrocuted by " + killerName + "s lightning.";
						break;
					case "Blaster":
						_loc5_ += player.name + " was blasted by " + killerName + ".";
						break;
					case "Piercing Gun":
						_loc5_ += player.name + " was perforated by " + killerName + ".";
						break;
					case "Gatling Gun":
						_loc5_ += player.name + " was perforated by " + killerName + "\'s gatling gun.";
						break;
					case "Acid Spray":
						_loc5_ += player.name + " was liquefied by " + killerName + "s acid.";
						break;
					case "Acid Blaster":
						_loc5_ += player.name + " was melted by " + killerName + "s acid.";
						break;
					case "Energy Nova":
						_loc5_ += player.name + " was shocked by " + killerName + ".";
						break;
					case "Nuke Launcher":
						_loc5_ += player.name + " was annihilated by " + killerName + "s nuke.";
						break;
					case "Heavy Cannon":
						_loc5_ += player.name + " was crushed by " + killerName + "s slugs.";
						break;
					case "Flamethrower":
						_loc5_ += player.name + " was burned alive by " + killerName + "s fire.";
						break;
					case "Broadside":
						_loc5_ += player.name + " received a broadside from " + killerName + ".";
						break;
					case "Moth Queen Spit Gland":
						_loc5_ += player.name + " was liquefied by " + killerName + "s acid.";
						break;
					case "Plankton Siphon Gland":
						_loc5_ += player.name + " was drained dry by " + killerName + ".";
						break;
					case "Cluster Missiles":
						_loc5_ += player.name + " was blown up by " + killerName + "s missiles.";
						break;
					case "Chrono Beam":
						_loc5_ += player.name + " was annihilated by " + killerName + "s Chrono Beam.";
						break;
					case "Moth Zero Gland":
						_loc5_ += player.name + " was disintegrated by " + killerName + "s Zero.";
						break;
					case "Particle Gun":
						_loc5_ += player.name + " was vaporized by " + killerName + "s neutron stream.";
						break;
					case "Piraya":
						_loc5_ += player.name + " was eaten alive by " + killerName + "s space fishes.";
						break;
					case "Prismatic Crystal":
						_loc5_ += player.name + " was disintegrated by " + killerName + "s prismatic crystals.";
						break;
					case "Razor":
						_loc5_ += player.name + " was sliced up by " + killerName + "s razors.";
						break;
					case "X27-S Smart Gun":
						_loc5_ += player.name + " couldn\'t dodge " + killerName + "s smart gun.";
						break;
					case "Blood-Claw S28 Smart Gun":
						_loc5_ += player.name + " couldn\'t dodge " + killerName + "s smart gun.";
						break;
					case "C-4":
						_loc5_ += player.name + " was blown up by " + killerName + "s C-4.";
						break;
					case "Concussion Sphere":
						_loc5_ += player.name + " was shocked to death by " + killerName + "s spheres.";
						break;
					case "Acid Spore":
						_loc5_ += player.name + " was infected by " + killerName + "s acid spores.";
						break;
					case "Eagle Needle":
						_loc5_ += player.name + " was perforated by " + killerName + "s needles.";
						break;
					case "Flame Trail":
						_loc5_ += player.name + " didn\'t see " + killerName + "s fiery trail.";
						break;
					case "Gatling Laser":
						_loc5_ += player.name + " was perforated by " + killerName + "s Gatling Laser.";
						break;
					case "Golden Gun":
						_loc5_ += player.name + " was shot by " + killerName + "s golden bullet.";
						break;
					case "Hell Fire":
						_loc5_ += player.name + " was burned to a crisp by " + killerName + "s Hellfire.";
						break;
					case "Infested Missiles":
						_loc5_ += player.name + " was liquified by " + killerName + "s infested missiles.";
						break;
					case "M2 Launcher":
						_loc5_ += player.name + " was hunted down by " + killerName + "s missiles.";
						break;
					case "Skeletor Lightning":
						_loc5_ += player.name + " was liquified by " + killerName + "s corrosive lightning.";
						break;
					case "Sticky Bombs":
						_loc5_ += player.name + " was blown up by " + killerName + "s bombs.";
						break;
					case "Astro Lance":
						_loc5_ += player.name + " was bludgeoned by " + killerName + "s lance.";
						break;
					case "Railgun":
						_loc5_ += player.name + " was eradicated by " + killerName + "s railgun";
						break;
					case "Nexar Projector":
						_loc5_ += player.name + " was scoped by " + killerName + "s projection";
						break;
					case "Vindicator Projector":
						_loc5_ += player.name + " was scoped by " + killerName + "s projection";
						break;
					case "Shadow Projector":
						_loc5_ += player.name + " was scoped by " + killerName + "s projection";
						break;
					case "Cruise Missiles VX-23":
						_loc5_ += player.name + " couldn’t escape  " + killerName + "s cruise missiles";
						break;
					case "Plasma Flares HG-168":
						_loc5_ += player.name + " was disintegrated by " + killerName + "s flares";
						break;
					case "Gatling Cannon GAU-186":
						_loc5_ += player.name + " was shattered by " + killerName + "s gatling cannon";
						break;
					case "Golden Gun :Scatter Shell":
						_loc5_ += player.name + " was pulverised by " + killerName + "s scattergun";
						break;
					case "Golden Gun :Flak Shell":
						_loc5_ += player.name + " was discombobulated by " + killerName + "s golden fireworks";
						break;
					case "Shadowflames":
						_loc5_ += player.name + " was scorched by " + killerName + "s flames";
						break;
					case "Death Cloud":
						_loc5_ += player.name + " was asphyxiated by " + killerName + "s cloud of death";
						break;
					case "Nexar Blaster":
						_loc5_ += killerName + " put an end to " + player.name;
						break;
					case "Corrosive Teeth":
						_loc5_ += player.name + " was torn apart by " + killerName + "s corrosive teeth";
						break;
					case "Viper Fangs":
						_loc5_ += player.name + " was torn apart by " + killerName + "s viperfangs";
						break;
					case "Poison Arrow":
						_loc5_ += player.name + " was shot down by " + killerName + "s poisoned arrow";
						break;
					case "Target Painter":
						_loc5_ += player.name + " was somehow killed by " + killerName + "s painter";
						break;
					case "Snow cannon":
						_loc5_ += player.name + " was frozen to death by " + killerName + "s snowball";
						break;
					case "Spore 83-X Smart Gun":
						_loc5_ += player.name + " couldn\'t dodge " + killerName + "s smart gun";
						break;
					case "Beamer":
						_loc5_ += player.name + " was fried by " + killerName + "s beamer";
						break;
					case "Larva lightning":
						_loc5_ += player.name + " was frazzled by " + killerName + "s larva";
						break;
					case "Boomerang":
						_loc5_ += player.name + " made mincemeat out of " + killerName + "s ship";
						break;
					case "Locust Hatchery":
						_loc5_ += player.name + " was tickled to death by " + killerName + "s locust swarm";
						break;
					case "Jaws":
						_loc5_ += player.name + " was eaten alive by " + killerName;
						break;
					case "Noxium Spray":
						_loc5_ += player.name + " was liquefied by " + killerName + "s noxium spray";
						break;
					case "Noxium BFG":
						_loc5_ += player.name + " was whomped by " + killerName + "s BFG";
						break;
					case "Aureus beam":
						_loc5_ += player.name + " was sentenced to death by " + killerName + "s Judibeam";
						break;
					case "Prismatic Easter Egg":
						_loc5_ += player.name + " received a colourful surprise from " + killerName + "s prismatic eggs";
						break;
					case "Algae Nova Gland":
						_loc5_ += player.name + " was crystallised by " + killerName + "s algae nova";
						break;
					case "Aureus lightning":
						_loc5_ += player.name + " was mercilessly executed by " + killerName + "s Aureus lightning";
						break;
					case "Fireworks":
						_loc5_ += killerName + " celebrated the death of " + player.name;
						break;
					case "Nexar Bomb":
						_loc5_ += player.name + " was wiped out by " + killerName + "s nexar bomb";
						break;
					case "Shadow Bomb":
						_loc5_ += player.name + " was wiped out by " + killerName + "s shadowbombs";
						break;
					case "Pixi Launcher":
						_loc5_ += player.name + " was pixelated by " + killerName;
						break;
					case "Photonic Blaster":
						_loc5_ += player.name + " was illuminated to death by " + killerName + "s photon stream";
						break;
					case "Sonic Missiles":
						_loc5_ += player.name + " couldn’t survive the shockwave from " + killerName + "s sonic missiles";
						break;
					case "Shadow Blaster":
						_loc5_ += player.name + " was assassinated from the shadows by " + killerName;
						break;
					case "Plasma Blaster":
						_loc5_ += player.name + " was melted by the blue fireballs of " + killerName;
						break;
					case "Plasma Torpedoes":
						_loc5_ += player.name + " was eviscerated by " + killerName + "s torpedoes";
						break;
					case "Kinetic Phase Cutter":
						_loc5_ += player.name + " was phased out of existence by " + killerName;
						break;
					case "Ram Missiles":
						_loc5_ += player.name + " was battered by " + killerName + "s ram missiles";
						break;
					case "Flak Cannon":
						_loc5_ += player.name + " was decimated by " + killerName + "s big metal scrap launcher";
						break;
					case "Golden Flak Cannon":
						_loc5_ += killerName + " unleashed a horde of shuriken upon " + player.name;
						break;
					case "Golden Ram Missiles":
						_loc5_ += player.name + " was shredded by " + killerName + "s golden ram";
						break;
					case "Vindicator Advanced Blaster":
						_loc5_ += player.name + " was demolished by " + killerName + "s advanced blaster";
						break;
					case "Vindicator Cluster Missiles":
						_loc5_ += player.name + " was ruptured by " + killerName + "s advanced blaster";
						break;
					case "X-73 Constructur":
						_loc5_ += killerName + "s guardian defended against " + player.name + "s ambush";
						break;
					case "Wasp Bait":
						_loc5_ += player.name + " was bitten by " + killerName + "s wasp";
						break;
					case "X-32 Constructor":
						_loc5_ += player.name + " was peppered by " + killerName + "s zlattes";
						break;
					case "Monachus":
						_loc5_ += player.name + " was annoyed to death by " + killerName + "s monachus";
						break;
					case "Aureus Energy Manipulator":
						_loc5_ += player.name + " couldn’t evade " + killerName + "s sentry energy orb";
						break;
					case "Aureus Kinetic Manipulator":
						_loc5_ += player.name + " couldn’t evade " + killerName + "s sentry kinetic orb";
						break;
					case "Aureus Corrosive Manipulator":
						_loc5_ += player.name + " couldn’t evade " + killerName + "s sentry corrosive orb";
						break;
					case "X-42 Constructor":
						_loc5_ += player.name + " was eliminated by " + killerName + "s army of triads";
						break;
					default:
						_loc5_ += player.name + " was killed by " + killerName;
				}
			}
			else
			{
				_loc5_ += player.name + " has died.";
			}
			var _loc4_:Object = {};
			_loc4_.type = "death";
			_loc5_ += "</FONT>";
			MessageLog.writeChatMsg("death",_loc5_);
		}
		
		private function get muted() : Array
		{
			return SceneBase.settings.chatMuted;
		}
		
		private function toggleView(view:String) : void
		{
			removeChild(simple);
			removeChild(advanced);
			activeView = activeView == view ? "" : view;
			if(activeView == "advanced")
			{
				addChild(advanced);
			}
			else
			{
				addChild(simple);
			}
		}
		
		public function toggleMuted(msgType:String, mute:Boolean) : void
		{
			var _loc4_:Array = muted;
			var _loc3_:int = int(_loc4_.indexOf(msgType));
			if(mute && _loc3_ == -1)
			{
				_loc4_.push(msgType);
			}
			else if(_loc3_ != -1)
			{
				_loc4_.splice(_loc3_,1);
			}
			SceneBase.settings.chatMuted = _loc4_;
			SceneBase.settings.save();
		}
		
		public function isMuted(msgType:String) : Boolean
		{
			return muted.indexOf(msgType) != -1;
		}
		
		public function removePlayerMessages(key:String) : void
		{
			textQueue = textQueue.filter(function(param1:Object, param2:int, param3:Vector.<Object>):Boolean
			{
				return (param1.playerKey || "") != key;
			});
		}
		
		public function getQueue() : Vector.<Object>
		{
			var queue:Vector.<Object> = textQueue.filter(function(param1:Object, param2:int, param3:Vector.<Object>):Boolean
			{
				var _loc4_:String = param1.type || "system";
				return muted.indexOf(_loc4_) == -1;
			});
			return queue;
		}
		
		private function update(e:Event = null) : void
		{
			if(contains(simple))
			{
				simple.update();
			}
		}
		
		public function updateTexts(obj:Object) : void
		{
			if(contains(advanced))
			{
				advanced.updateText(obj);
			}
			else if(contains(simple))
			{
				simple.updateTexts();
			}
		}
		
		override public function dispose() : void
		{
			removeEventListeners();
			g = null;
			super.dispose();
		}
	}
}

