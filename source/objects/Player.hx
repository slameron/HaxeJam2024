package objects;

/**
 * uses code from GeoKureli's Dial-A-Platformer
 */
class Player extends FlxSprite
{
	var controls(get, never):Controls;

	function get_controls()
		return Init.controls;

	public var canMove:Bool = true;

	var speed:Float = 0;
	var jumpSpeed:Float = 0;
	var jumpTime:Float = 0;
	var jumpTimer:Float = 0;

	var minJumpHeight:Float = 1.15 * 18;
	var maxJumpHeight:Float = 3.25 * 18;
	var jumpDistance:Float = 6 * 18;
	var timeToJump:Float = .5;

	var coyoteTime:Float = .2;
	var coyoteTimer:Float = 0;

	var gravity:Float = 400;
	var timeToStop:Float = .15;
	var timeToMaxSpeed:Float = .15;

	override public function new(x:Float, y:Float, name:String)
	{
		super(x, y);
		setupStuff();

		loadGraphic('assets/images/${name}platformer.png', true, 18, 18);
		switch (name)
		{
			case 'kitty':
				animation.add('idle', [0, 1, 2, 3], 4);
				animation.add('walk', [5, 6, 7, 8], 6);
				animation.add('jump', [4], 4);

			case 'wizard':
				animation.add('idle', [0], 4);
				animation.add('walk', [1, 2, 3, 4], 6);
				animation.add('jump', [5], 4);
		}

		animation.play('idle');
		acceleration.y = gravity;
		maxVelocity.x = speed;
		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
	}

	function setupJump(height:Float, timeToApex:Float)
	{
		gravity = 2 * height / timeToApex / timeToApex;
		jumpSpeed = 2 * height / timeToApex;
	}

	function setupStuff()
	{
		setupJump(minJumpHeight, 2 * timeToJump * minJumpHeight / (minJumpHeight + maxJumpHeight));
		jumpTime = (maxJumpHeight - minJumpHeight) / jumpSpeed;

		var timeToApex = jumpSpeed / gravity + jumpTime;
		speed = jumpDistance / timeToApex / 2;
	}

	override public function update(elapsed:Float)
	{
		if (canMove)
		{
			updateMovement(elapsed);
			updateAnims();
		}

		super.update(elapsed);
	}

	function updateMovement(elapsed:Float)
	{
		coyoteTimer += elapsed;
		if (isTouching(FLOOR))
			coyoteTimer = 0;
		if (isTouching(CEILING))
			jumpTimer = jumpTime;

		if (controls.pressed('left'))
			acceleration.x = -speed / timeToMaxSpeed;
		if (controls.pressed('right'))
			acceleration.x = speed / timeToMaxSpeed;
		if ((controls.pressed('left') && controls.pressed('right')) || (!controls.pressed('left') && !controls.pressed('right')))
		{
			acceleration.x = 0;
			timeToStop == 0 ? velocity.x = 0 : drag.x = speed / timeToStop / timeToStop;
		}

		if (controls.justPressed('jump') && getOnCoyoteGround())
		{
			jumpTimer = 0;
			jump();
		}
		else if (controls.pressed('jump') && jumpTimer < jumpTime)
		{
			jumpTimer += elapsed;
			jump();
		}
		else if (controls.justReleased('jump'))
			jumpTimer = jumpTime;
	}

	function updateAnims()
	{
		facing = velocity.x > 0 ? RIGHT : velocity.x < 0 ? LEFT : facing;

		if (velocity.x != 0)
			animation.play('walk');
		else
			animation.play('idle');

		if (!touching.has(FLOOR))
			animation.play('jump');

		FlxG.watch.addQuick('Touching', touching);
		FlxG.watch.addQuick('anim', animation.curAnim.name);
	}

	function jump()
	{
		velocity.y = -jumpSpeed;
		acceleration.y = gravity;
	}

	inline function getOnCoyoteGround():Bool
	{
		return coyoteTimer < coyoteTime || isTouching(FLOOR);
	}
}
