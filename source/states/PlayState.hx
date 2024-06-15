package states;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;

using StringTools;

class PlayState extends DefaultState
{
	var collisions:FlxGroup;
	var interactables:FlxTypedGroup<Interactable>;
	var player:Player;
	var enemies:FlxTypedGroup<Enemy>;

	var level:String;

	override public function new(level:String)
	{
		super();
		this.level = level;
	}

	override public function create()
	{
		super.create();

		FlxG.camera.zoom = 3;

		if (Sound.gameMus == null)
			Sound.gameMus = Sound.playMusic('ajourneyawaits-pbondoer');
		else if (!Sound.gameMus.playing)
		{
			Sound.gameMus.resume();
			Sound.gameMus.pitch = 1;
		}

		var project = new FlxOgmo3Loader('assets/data/haxejam2024.ogmo', 'assets/data/levels/$level.json');

		var bg = project.loadTilemap('assets/images/kenney_pixel-platformer/Tilemap/tilemap-backgrounds_packed.png', 'bg');
		bg.scrollFactor.set(.65, .65);
		add(bg);
		collisions = new FlxGroup();
		add(collisions);
		var tilemap = project.loadTilemap('assets/images/kenney_pixel-platformer/Tilemap/tilemap_packed.png', 'ground');
		tilemap.follow(FlxG.camera, 1);
		collisions.add(tilemap);

		for (i in 17...21)
			tilemap.setTileProperties(i, CEILING); // treetops
		for (i in 38...42)
			tilemap.setTileProperties(i, NONE); // treetops
		for (i in 60...63)
			tilemap.setTileProperties(i, NONE); // treetops
		for (i in 81...84)
			tilemap.setTileProperties(i, CEILING); // treetops
		for (i in 89...94)
			tilemap.setTileProperties(i, NONE); // signs
		for (i in 101...104)
			tilemap.setTileProperties(i, NONE); // trees
		for (i in 104...105)
			tilemap.setTileProperties(i, CEILING); // tree branches
		tilemap.setTileProperties(122, NONE); // trees
		for (i in 123...126)
			tilemap.setTileProperties(i, CEILING); // tree branches
		tilemap.setTileProperties(124, NONE);
		for (i in 131...135)
			tilemap.setTileProperties(i, NONE); // grass
		for (i in 143...146)
			tilemap.setTileProperties(i, NONE); // tree stump/branch

		tilemap.setTileProperties(146, NONE); // tree branches
		for (i in 154...156)
			tilemap.setTileProperties(i, CEILING); // platforms
		for (i in 161...165)
			tilemap.setTileProperties(i, CEILING); // clouds

		enemies = new FlxTypedGroup();
		add(enemies);

		interactables = new FlxTypedGroup();
		add(interactables);

		project.loadEntities(loadEntity, 'entities');

		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		persistentUpdate = true;
	}

	function loadEntity(e:EntityData)
	{
		switch (e.name)
		{
			case 'spawn':
				player = new Player(e.x, e.y, FlxG.random.getObject(['kitty', 'wizard']));
				FlxG.camera.follow(player, LOCKON, 0.25);

				add(player);

			case 'enemy':
				var enemy = new Enemy(e.x, e.y, e.values.type, e.nodes);
				enemy.immovable = true;
				enemies.add(enemy);
				enemy.numEnemies = FlxG.random.int(1, 3);
				if (e.values.type == 'Boss')
					enemy.numEnemies = 1;

			case 'sign':
				var sign = new Interactable(e.x, e.y, 'interact', 'assets/images/kenney_pixel-platformer/kenneysign.png', 18);
				sign.animation.add('neutral', [0]);
				sign.animation.add('left', [1]);
				sign.animation.add('right', [2]);
				sign.animation.play(e.values.facing);
				interactables.add(sign);

				if (e.values.canRead)
				{
					sign.canHover = true;
					sign.onInteract = () ->
					{
						sign.canHover = sign.canInteract = false;
						var text:String = e.values.text;
						var textA = text.split('\\n');
						for (text in textA)
							new PopUpUI(text, true, 'menu_accept', null, () ->
							{
								sign.canHover = sign.canInteract = true;
							});
					};
				}
		}
	}

	override public function update(elapsed:Float)
	{
		FlxG.collide(player, collisions);
		FlxG.collide(player, enemies, collideWithEnemy);

		interactables.forEach(i -> i.hovered = false);
		FlxG.overlap(player, interactables, (p:Player, i:Interactable) -> i.hovered = true);

		enemies.forEachAlive(e -> if (e.fled) if (!FlxG.overlap(player, e))
		{
			e.fled = false;
			e.allowCollisions = ANY;
		});
		super.update(elapsed);
	}

	var collided:Bool = false;

	function collideWithEnemy(p:Player, e:Enemy)
	{
		if (!collided && !e.fled)
		{
			var playerAdvantage:Bool = false;
			e.allowCollisions = NONE;
			if (!p.wasTouching.has(FLOOR) && p.isTouching(FLOOR))
				playerAdvantage = true;

			subStateClosed.addOnce(sub ->
			{
				collided = false;
				p.canMove = true;
				if (Sound.gameMus != null)
				{
					Sound.gameMus.resume();
					FlxTween.tween(Sound.gameMus, {'pitch': 1}, 1.5);
				}
				new FlxTimer().start(2, tmr -> e.startPath());
				FlxTween.tween(FlxG.camera, {'zoom': 3}, .75, {
					ease: FlxEase.smootherStepInOut
				});
			});
			collided = true;
			p.velocity.set();
			p.facing = p.x + p.width / 2 > e.x + e.width / 2 ? LEFT : RIGHT;
			e.facing = e.x + e.width / 2 > p.x + p.width / 2 ? LEFT : RIGHT;
			if (e.path != null)
				e.path.cancel();
			if (e.pathTimer != null)
				e.pathTimer.cancel();
			p.acceleration.x = 0;
			p.canMove = false;

			p.animation.play('idle');
			if (Sound.gameMus != null)
				FlxTween.tween(Sound.gameMus, {'pitch': 0.01}, 1.5, {onComplete: twn -> Sound.gameMus.pause()});
			FlxTween.tween(FlxG.camera, {'zoom': 6}, .75, {
				ease: FlxEase.smootherStepOut,
				onComplete: twn -> if (subState == null)
				{
					new FlxTimer().start(1, tmr -> openSubState(new BattleSubstate([for (i in 0...e.numEnemies) e.type], playerAdvantage, e)));
				}
			});

			FlxG.camera.flash(FlxColor.WHITE, .25);
		}
	}
}
