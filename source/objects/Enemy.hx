package objects;

import flixel.path.FlxPath;

class Enemy extends FlxSprite
{
	var nodes:Array<{x:Float, y:Float}>;

	public var type:String;
	public var pathTimer:FlxTimer;
	public var fled:Bool = false;
	public var numEnemies:Int;

	override public function new(x:Float, y:Float, name:String, nodes:Array<{x:Float, y:Float}>)
	{
		super(x, y);

		if (nodes != null)
			nodes.insert(0, {x: x, y: y});

		type = name;

		switch (name)
		{
			case 'Slime':
				loadGraphic('assets/images/slime.png', true, 18, 8);
				this.y += 10;

				for (node in nodes)
					node.y += 14;
				animation.add('idle', [0, 1, 2, 3], 6);
				animation.play('idle');

			case 'Skeleton':
				loadGraphic('assets/images/skeleton.png', true, 18, 18);
				for (node in nodes)
					node.y += 9; // I guess nodes are the midpoints? maybe idk
				animation.add('idle', [0, 1, 2, 3], 5);
				animation.add('walk', [4, 5, 6, 7], 5);
				animation.play('idle');

			case 'Boss':
				loadGraphic('assets/images/boss.png');
				facing = LEFT;
		}
		this.nodes = nodes;

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
		if (nodes != null)
			startPath();
	}

	public function startPath()
	{
		if (nodes == null)
			return;

		path = new FlxPath().start([for (i in nodes) FlxPoint.get(i.x, i.y)], 50, FORWARD);
		path.onComplete = p ->
		{
			var n = p.nodes;
			n.reverse();

			pathTimer = new FlxTimer().start(1, tmr ->
			{
				path.start(n, 50, FORWARD);
				pathTimer = null;
			});
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		facing = velocity.x > 0 ? RIGHT : velocity.x < 0 ? LEFT : facing;

		if (animation.exists('walk'))
			if (velocity.x != 0)
				animation.play('walk');
			else
				animation.play('idle');
	}
}
