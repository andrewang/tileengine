package z_spark.tileengine.tile
{
	import z_spark.tileengine.math.MathUtil;
	import z_spark.tileengine.math.Vector2D;

	public class TileBase
	{
		protected var _type:int;
		protected var _row:int;
		protected var _col:int;
		
		public function TileBase(type:int,row:int,col:int)
		{
			_type=type;
			_row=row;
			_col=col;
		}
		
		public function get col():int
		{
			return _col;
		}
		
		public function get row():int
		{
			return _row;
		}
		
		protected function fixTarget(planeDir:Vector2D,planeGolbalPos:Vector2D, targetPos:Vector2D,targetSpd:Vector2D):Boolean
		{
			//检查targetSpd的速度方向是否与该格子正方向同向；
			var dir_spd_projection:Number=MathUtil.dotProduct(targetSpd,planeDir);
			if(dir_spd_projection<0){
				//计算目标点到平面的距离；
				var tmp:Vector2D=planeGolbalPos.clone();
				tmp.sub(targetPos);
				var dis_half:Number=MathUtil.dotProduct(planeDir,tmp);
				if(dis_half>0){
					//物体已经穿过了斜面；
					/*计算位置*/
					tmp.resetV(planeDir);
					tmp.mul(2*dis_half);
					targetPos.add(tmp);
					
					/*计算速度*/
					tmp.resetV(planeDir);
					tmp.mul(-2*dir_spd_projection);
					targetSpd.add(tmp);
				}
			}
			return false;
		}
	}
}