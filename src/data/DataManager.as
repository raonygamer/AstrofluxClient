package data
{
	import com.adobe.serialization.json.JSONDecoder;
	import core.artifact.Artifact;
	import debug.Console;
	import flash.utils.ByteArray;
	import playerio.*;
	import starling.display.Sprite;
	
	public class DataManager extends Sprite implements IDataManager
	{
		private var _client:Client;
		
		private var json:Object;
		
		public var _artifacts:Vector.<Artifact> = new Vector.<Artifact>();
		
		public function DataManager(client:Client)
		{
			super();
			this._client = client;
		}
		
		public function getArtifacts() : Vector.<Artifact>
		{
			return _artifacts;
		}
		
		public function setClient(value:Client) : void
		{
			_client = value;
		}
		
		public function loadKeyFromBigDB(table:String, key:String, callback:Function) : void
		{
			if(table == null || key == null || table.length == 0 || key.length == 0)
			{
				Console.write("BigDB: key or table is empty or null, key:" + key + " table:" + table);
				return;
			}
			loadFromBigDB(table,key,callback);
		}
		
		private function loadFromBigDB(table:String, key:String, callback:Function) : void
		{
			_client.bigDB.load(table,key,function(param1:DatabaseObject):void
			{
				try
				{
					callback(param1);
				}
				catch(e:Error)
				{
					_client.errorLog.writeError(e.toString(),"loadFromBigDB failed, table: " + table + ", key: " + key,e.getStackTrace(),{});
				}
			},function(param1:PlayerIOError):void
			{
				Console.write("FAILED DATA - TABLE: " + table + " KEY: " + key + " ERROR: " + param1.name);
			});
		}
		
		public function loadRangeFromBigDB(table:String, index:String, indexPath:Array = null, callback:Function = null, maxCount:int = 1000) : void
		{
			_client.bigDB.loadRange(table,index,indexPath,null,null,maxCount,function(param1:Array):void
			{
				callback(param1);
			},function(param1:PlayerIOError):void
			{
				Console.write("FAILED DATA - TABLE: " + table + " INDEX: " + index + " INDEX_PATH: " + indexPath + " ERROR: " + param1);
			});
		}
		
		public function loadKeysFromBigDB(table:String, keys:Array, callback:Function = null) : void
		{
			var key:String;
			var n:int = int(keys.length);
			var i:int = n - 1;
			while(i > -1)
			{
				key = keys[i];
				if(IsNullOrEmpty(key))
				{
					keys.splice(keys.indexOf(key),1);
				}
				i--;
			}
			_client.bigDB.loadKeys(table,keys,function(param1:Array):void
			{
				callback(param1);
			},function(param1:PlayerIOError):void
			{
				Console.write("FAILED DATA - TABLE: " + table + " KEYS: " + keys + " ERROR: " + param1);
			});
		}
		
		private function IsNullOrEmpty(key:String) : Boolean
		{
			if(key == null || key == "" || key == " ")
			{
				return true;
			}
			return false;
		}
		
		public function loadKey(table:String, key:String) : Object
		{
			if(IsNullOrEmpty(table))
			{
				Console.write("error table is null in loadKey");
				return null;
			}
			if(IsNullOrEmpty(key))
			{
				Console.write("error key: " + key + " is null in loadKey for table " + table);
				return null;
			}
			if(!json.hasOwnProperty(table) || !json[table].hasOwnProperty(key))
			{
				Console.write("error key missing i json cache, table: " + table + ", key: " + key);
				return null;
			}
			return json[table][key];
		}
		
		public function loadKeys(table:String, keys:Array) : Array
		{
			var _loc4_:Object = null;
			var _loc3_:Array = [];
			for each(var _loc5_ in keys)
			{
				_loc4_ = loadKey(table,_loc5_);
				_loc4_.key = _loc5_;
				_loc3_.push(_loc4_);
			}
			return _loc3_;
		}
		
		public function loadTable(table:String) : Object
		{
			if(!json.hasOwnProperty(table))
			{
				Console.write("error table is missing in cache, table: " + table);
				return null;
			}
			return json[table];
		}
		
		public function loadRange(table:String, property:String, compareValue:String) : Object
		{
			var _loc5_:Object = null;
			if(!json.hasOwnProperty(table))
			{
				Console.write("error table missing i json cache, table: " + table);
				return null;
			}
			var _loc4_:Object = {};
			for(var _loc6_ in json[table])
			{
				_loc5_ = json[table][_loc6_];
				if(_loc5_.hasOwnProperty(property))
				{
					if(_loc5_[property] == compareValue)
					{
						_loc4_[_loc6_] = _loc5_;
					}
				}
			}
			return _loc4_;
		}
		
		public function loadFirstByProperty(table:String, property:String, compareValue:String) : Object
		{
			var _loc4_:Object = null;
			if(!json.hasOwnProperty(table))
			{
				Console.write("error table missing i json cache, table: " + table);
				return null;
			}
			for(var _loc5_ in json[table])
			{
				_loc4_ = json[table][_loc5_];
				if(_loc4_.hasOwnProperty(property))
				{
					if(_loc4_[property] == compareValue)
					{
						return _loc4_;
					}
				}
			}
			return null;
		}
		
		public function cacheCommonData() : void
		{
			var _loc2_:ByteArray = new EmbeddedAssets.CacheFile() as ByteArray;
			var _loc1_:JSONDecoder = new JSONDecoder(_loc2_.readUTFBytes(_loc2_.length),true);
			json = _loc1_.getValue();
		}
	}
}

