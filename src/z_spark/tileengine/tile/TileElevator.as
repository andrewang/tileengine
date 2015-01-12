package z_spark.tileengine.tile
{
	import z_spark.tileengine.TileMap;
	import z_spark.tileengine.constance.ElementStatus;
	import z_spark.tileengine.constance.TileDir;
	import z_spark.tileengine.constance.TileHandleStatus;
	import z_spark.tileengine.constance.TileWorldConst;
	import z_spark.tileengine.math.MathUtil;
	import z_spark.tileengine.math.Vector2D;
	import z_spark.tileengine.primitive.IElement;
	
	public class TileElevator extends TileBase implements ITile,IDynamic
	{
		private var _localPos:Vector2D;
		private var _positiveVct:Vector2D;//referance
		
		public function TileElevator(tilemap:TileMap, type:int, row:int, col:int,pos:Vector2D,dirv:Array)
		{
			super(tilemap, type, row, col);
			_localPos=pos.clone();
			CONFIG::DEBUG{
				_dirArray=dirv;
			};
			_positiveVct=dirv[0];
			_fixTeleport=true;
		}
		
		public function get fixVector():Vector2D
		{
			return _fixVector;
		}

		public function handleTileMove(tilesize:uint, gravity:Vector2D, elem:IElement, testPos:Vector2D=null):int
		{
			elem.position.add(_fixVector);
			//计算移动的速度在该格子平面上的切向投影；
			//该投影就是在斜面上的切向速度；
			var globalPos:Vector2D=new Vector2D(_localPos.x+_col*tilesize,_localPos.y+_row*tilesize);
			globalPos.sub(elem.position);
			
			elem.position.addScale(_positiveVct,MathUtil.dotProduct(_positiveVct,globalPos)+TileWorldConst.MIN_NUMBER);
			
			return TileHandleStatus.ST_PASS;
		}
		
		public function testCollision(tilesize:uint, gravity:Vector2D, elem:IElement):int
		{
			elem.position.add(_fixVector);
			var globalPos:Vector2D=new Vector2D(_localPos.x+_col*tilesize,_localPos.y+_row*tilesize);
			//计算目标点到平面的距离；
			var tmp:Vector2D=globalPos.clone();
			tmp.sub(elem.position);
			var dis_half:Number=MathUtil.dotProduct(_positiveVct,tmp);
			if(dis_half>0 ){
				if(_fixTeleport){
					tmp.reset(globalPos);
					tmp.sub(elem.lastPosition);
					var dis_half2:Number=MathUtil.dotProduct(_positiveVct,tmp);
					if(dis_half2>=0)return TileHandleStatus.ST_PASS;
				}
				var targetSpd:Vector2D=elem.velocity;
				//计算目标点到平面的距离；
				//物体已经穿过了斜面；
				/*位置*/
				tmp.resetScale(_positiveVct,TileWorldConst.MIN_NUMBER+dis_half);
				elem.position.add(tmp);
				
				/*速度衰减,切向与法向；*/
				var n:Vector2D=_positiveVct.clone();
				n.mul(MathUtil.dotProduct(targetSpd,_positiveVct));
				var t:Vector2D=n.clone();
				t.sub(targetSpd);
				targetSpd.addScale(n,-(2-_bounceFactor));
				targetSpd.addScale(t,_frictionFactor);
				
				var mag:Number=gravity.mag;
				if(dis_half<=mag && targetSpd.mag<mag){
					elem.removeStatus(ElementStatus.JUMP);
				}
				
				CONFIG::DEBUG_DRAW_TIMELY{
					if(_recovered){
						TileDebugger.debugDraw(this);
						_intervalId=setTimeout(recoverDebugDraw,200);
						_recovered=false;
					}
				};
				
				return TileHandleStatus.ST_FIXED;
			}
			return TileHandleStatus.ST_PASS;
		}
		
		CONFIG::DEBUG{
			public function toString():String{
				return "[ type:"+_type+",col:"+_col+",row:"+_row+",dirVct:"+_positiveVct.toString()+" ]";
			}
			
			private var _dirArray:Array;//referance
			public function get dirArray():Array{
				return _dirArray;
			}
		};
		
		private var _fixVector:Vector2D=new Vector2D(0,-0.2);
		private var _maxSteps:uint=300;
		private var _nowStep:uint=0;
		public function update(tilesize:uint):int
		{
			_nowStep++;
			if(_nowStep>=_maxSteps){
				_nowStep=0;
				_fixVector.y*=-1;
			}
			
			_localPos.add(_fixVector);
			if(_localPos.y>tilesize){
				_localPos.y-=tilesize;
				_tilemap.switchTileByDir(this,TileDir.DIR_DOWN);
			}else if(_localPos.y<0){
				_localPos.y=tilesize+_localPos.y;
				_tilemap.switchTileByDir(this,TileDir.DIR_TOP);
			}
			return 0;
		}
		
	}
}