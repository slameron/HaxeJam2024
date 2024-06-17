package states;

import flixel.sound.FlxSound;

class BattleSubstate extends DefaultSubstate
{
	/**
	 * Create battle state
	 * @param enemyTypes The types of enemies. either `slime` or `skeleton` for now
	 * @param playerAdvantage Whether or not the player should go first
	 */
	override public function new(enemyTypes:Array<String>, playerAdvantage:Bool, collidedEnemy:Enemy)
	{
		super();

		canEsc = false;

		if (enemyTypes.contains('Boss'))
			music = Sound.playMusic('gloom-souljahdeshiva');
		else
			music = Sound.playMusic('battlesong-djsaryon');

		var wizard = new FlxSprite().loadGraphic('assets/images/wizardSprite.png', true, 139, 84);
		wizard.animation.add('idle', [0]);
		wizard.animation.add('hurt', [1, 2, 3, 4], 6);
		wizard.animation.add('died', [5]);
		wizard.animation.add('attack', [6]);
		wizard.animation.play('idle');
		var kitty = new FlxSprite().loadGraphic('assets/images/kittySprite.png', true, 86, 79);
		kitty.animation.add('idle', [0]);
		kitty.animation.add('hurt', [1, 2, 3, 4], 6);
		kitty.animation.add('died', [5]);
		kitty.animation.add('attack', [6]);
		kitty.animation.play('idle');

		wizard.scale.set(3, 3);
		wizard.updateHitbox();
		kitty.scale.set(3, 3);
		kitty.updateHitbox();
		add(wizard);
		add(kitty);
		kitty.setPosition(20, 50 + wizard.height - 20);
		wizard.setPosition(kitty.x + kitty.width / 2, 50);

		characters.set('Neko', kitty);
		characterStats.set('Neko', {mana: 100, health: 150, maxHealth: 150});
		characters.set('Melvin', wizard);
		characterStats.set('Melvin', {mana: 125, health: 100, maxHealth: 100});

		var twnwX = wizard.x;
		wizard.x = 0 - wizard.width;
		FlxTween.tween(wizard, {x: twnwX}, 1, {ease: FlxEase.smootherStepInOut, startDelay: .5});

		var twnkX = kitty.x;
		kitty.x = 0 - kitty.width;
		FlxTween.tween(kitty, {x: twnkX}, 1, {ease: FlxEase.smootherStepInOut, startDelay: .75});

		for (i in 0...enemyTypes.length)
		{
			var enemy = enemyTypes[i];
			var w:Int = 0;
			var h:Int = 0;

			switch (enemy)
			{
				case 'Slime':
					w = 146;
					h = 90;

				case 'Skeleton':
					w = 95;
					h = 102;
				case 'Boss':
					w = 163;
					h = 198;
			}

			var e = new FlxSprite().loadGraphic('assets/images/Fight$enemy.png', true, w, h);
			e.animation.add('idle', [0]);
			e.animation.add('hurt', [1, 2, 3, 4], 6);
			e.animation.add('died', [5]);
			e.animation.add('attack', [6]);
			e.animation.play('idle');
			e.scale.set(3, 3);
			e.updateHitbox();

			var spacing = FlxG.height / enemyTypes.length;

			e.setPosition(FlxG.width - e.width - (i % 2 == 1 ? 30 : 120), ((spacing * i) + spacing / 2 - e.height / 2) / 2);
			add(e);

			var twneX = e.x;
			e.x = FlxG.width;
			FlxTween.tween(e, {x: twneX}, 1, {ease: FlxEase.smootherStepInOut, startDelay: 1.25 + (.25 * i)});

			characters.set('${enemy} ${i + 1}', e);
			var enemyHealth:Int = FlxG.random.int(3, 7) * 10;

			if (enemy == 'Boss')
				enemyHealth = 250;
			characterStats.set('${enemy} ${i + 1}', {mana: 0, health: enemyHealth, maxHealth: enemyHealth});
		}

		trace(characterStats);

		var advantageText = new Text(0, 0, 0, '${playerAdvantage ? 'PLAYER' : 'ENEMY'} ADVANTAGE!', 64);
		advantageText.scale.set(5, 5);
		advantageText.alpha = 0;
		advantageText.angle = 360 * 5;
		advantageText.screenCenter();
		advantageText.y -= advantageText.height;
		add(advantageText);
		FlxTween.tween(advantageText, {
			'scale.x': 1,
			'scale.y': 1,
			'angle': 0,
			'alpha': 1
		}, 1, {
			ease: FlxEase.smootherStepIn,
			startDelay: 2.25,
			onComplete: twn ->
			{
				subCam.shake(.025, .25);
				new FlxTimer().start(1.5, tmr ->
				{
					advantageText.origin.x = advantageText.width - 5;
					FlxTween.angle(advantageText, 0, -8, .25, {
						ease: FlxEase.backOut,
						onComplete: twn -> FlxTween.tween(advantageText, {y: FlxG.height + 100, 'angle': -30}, .75,
							{ease: FlxEase.smootherStepIn, startDelay: .35})
					});
				});
			}
		});

		if (playerAdvantage)
		{
			FlxG.save.data.playerAdvantages++;
			FlxG.save.flush();

			if (FlxG.save.data.playerAdvantages >= 10)
				achievements.unlock('Advantage Seeker');
		}

		playerTurn = playerAdvantage;
		battleUI = new BattleUI(0, 0, () ->
		{
			collidedEnemy.fled = true;

			close();
		});
		this.collidedEnemy = collidedEnemy;
		battleUI.enemies = [for (i in 0...enemyTypes.length) '${enemyTypes[i]} ${i + 1}'];
		for (i in battleUI.enemies)
			battleUI.charactersAlive.set(i, true);

		battleUI.charactersAlive.set('Melvin', true);
		battleUI.charactersAlive.set('Neko', true);
		add(battleUI);
		battleUI.addHealthTexts();
		battleUI.adjustPosition(FlxG.width / 2 - battleUI.bg.width / 2, FlxG.height - battleUI.bg.height - 30);

		if (playerAdvantage)
			turnOrder = ['Melvin', 'Neko'].concat([for (i in 0...enemyTypes.length) '${enemyTypes[i]} ${i + 1}']);
		else
			turnOrder = [for (i in 0...enemyTypes.length) '${enemyTypes[i]} ${i + 1}'].concat(['Melvin', 'Neko']);

		new FlxTimer().start(6, tmr ->
		{
			battleUI.ready = battleReady = true;
			trace('ready for battle!');

			nextTurn();
		});
	}

	override public function close()
	{
		super.close();
		music.fadeOut(.5, 0);
	}

	var music:FlxSound;
	var turnOrder:Array<String>;
	var collidedEnemy:Enemy;
	var battleUI:BattleUI;
	var battleReady:Bool = false;
	var playerTurn:Bool = false;
	var characters:Map<String, FlxSprite> = [];
	var characterGuarding:Map<String, Bool> = [];

	public var characterStats:Map<String, {mana:Int, health:Int, maxHealth:Int}> = [];

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (battleReady)
		{
			battleUI.ready = playerTurn;

			if (playerTurn)
			{
				if (battleUI.target != null && battleUI.action != null)
				{
					playerTurn = false;
					var turn = turnOrder[turnOrder.length - 1];
					var name = turn.split(' ');

					var character = characters.get(name[0]);
					var target = characters.get(battleUI.target);
					switch (battleUI.action)
					{
						case 'Fireball':
							battleUI.statusText.text = '${name[0]} casts a fireball on ${battleUI.target}!';

							var oldPos = character.getPosition();

							FlxTween.tween(character, {x: FlxG.width / 2 - character.width, y: target.y + target.height / 2 - character.height / 2}, 1, {
								ease: FlxEase.smootherStepInOut,
								onComplete: twn ->
								{
									new FlxTimer().start(.75, tmr ->
									{
										subCam.shake(.01, .15);
										character.animation.play('attack');

										var blast = new FlxSprite().loadGraphic('assets/images/kittyblast.png');
										blast.scale.set(character.scale.x, character.scale.y);
										blast.updateHitbox();
										blast.setPosition(character.x + character.width / 2, character.y + character.height / 2 - blast.height / 2);
										add(blast);
										blast.scale.set(0, 0);
										FlxTween.tween(blast, {'scale.x': character.scale.x, 'scale.y': character.scale.y}, .25);
										FlxTween.tween(blast, {x: target.x + target.width / 2}, .75, {
											onComplete: twn ->
											{
												remove(blast);
												character.animation.play('idle');
												target.animation.play('hurt');
												Sound.play('boom');
												hurt(battleUI.target, null, 20, 35);
												new FlxTimer().start(.75, tmr ->
												{
													target.animation.play('idle');
													if (!battleUI.charactersAlive.get(battleUI.target))
														target.animation.play('died');
													FlxTween.tween(character, {x: oldPos.x, y: oldPos.y}, 1,
														{ease: FlxEase.smootherStepInOut, onComplete: twn -> nextTurn(), startDelay: .5});
												});
											}
										});
									});
								}
							});
						case 'Shockwave':
							battleUI.statusText.text = '${name[0]} casts a shockwave on ${battleUI.target}!';

							var oldPos = character.getPosition();
							FlxTween.tween(character,
								{x: target.x - character.width + character.width / 3, y: target.y + target.height / 2 - character.height / 2}, 1, {
									ease: FlxEase.smootherStepInOut,
									onComplete: twn ->
									{
										new FlxTimer().start(.75, tmr ->
										{
											subCam.shake(.01, .15);
											character.animation.play('attack');
											target.animation.play('hurt');
											Sound.play('electric');
											hurt(battleUI.target, null, 25, 40);

											var blast = new FlxSprite().loadGraphic('assets/images/wizardblast.png');
											blast.scale.set(character.scale.x, character.scale.y);
											blast.updateHitbox();
											blast.setPosition(character.x, character.y);
											add(blast);

											new FlxTimer().start(.75, tmr ->
											{
												remove(blast);
												character.animation.play('idle');
												target.animation.play('idle');
												if (!battleUI.charactersAlive.get(battleUI.target))
													target.animation.play('died');

												FlxTween.tween(character, {x: oldPos.x, y: oldPos.y}, 1,
													{ease: FlxEase.smootherStepInOut, onComplete: twn -> nextTurn(), startDelay: .5});
											});
										});
									}
								});

						case 'BossFlee':
							battleUI.statusText.text = 'You can\'t escape the boss!';
							new FlxTimer().start(2, tmr ->
							{
								turnOrder.insert(0, turnOrder.pop());
								nextTurn();
							});
						case 'Flee':
							battleUI.statusText.text = 'Successfully fled the battle!';
							FlxTween.tween(characters.get('Neko'), {x: -300}, 1, {ease: FlxEase.smootherStepIn});
							FlxTween.tween(characters.get('Melvin'), {x: -300}, 1, {ease: FlxEase.smootherStepIn});
							new FlxTimer().start(2, tmr -> if (battleUI.onFlee != null) battleUI.onFlee());
						case 'FailEscape':
							battleUI.statusText.text = '${name[0]} couldn\'t get away from the fight!';
							new FlxTimer().start(2, tmr -> nextTurn());

						case 'Attack':
							var oldPos = character.getPosition();
							battleUI.statusText.text = '${name[0]} attacks ${battleUI.target}!';
							FlxTween.tween(character, {
								x: target.x - character.width / 3,
								y: target.y + target.height / 2 - character.height / 2
							}, 1, {
								ease: FlxEase.smootherStepInOut,
								onComplete: twn ->
								{
									new FlxTimer().start(.5, tmr ->
									{
										character.animation.play('attack');
										target.animation.play('hurt');
										Sound.play('hurt${battleUI.target.split(' ')[0]}');
										hurt(battleUI.target, null, 10, 25);
										subCam.shake(.01, .15);
										FlxTween.tween(character, {x: character.x + 30}, .25, {ease: FlxEase.backOut});
										new FlxTimer().start(.5, tmr ->
										{
											character.animation.play('idle');
											target.animation.play('idle');
											if (!battleUI.charactersAlive.get(battleUI.target))
												target.animation.play('died');
											FlxTween.tween(character, {x: oldPos.x, y: oldPos.y}, 1,
												{ease: FlxEase.smootherStepInOut, startDelay: .25, onComplete: twn -> nextTurn()});
										});
									});
								}
							});

						case 'Heal':
							var healAmount = FlxG.random.int(10, 25);
							battleUI.statusText.text = '${name[0]} heals ${battleUI.target} for $healAmount health!';

							hurt(battleUI.target, -healAmount);
							if (characterStats.get(battleUI.target).health > characterStats.get(battleUI.target).maxHealth)
								characterStats.get(battleUI.target).health = characterStats.get(battleUI.target).maxHealth;

							new FlxTimer().start(2.5, tmr -> nextTurn());

						case 'Guard':
							battleUI.statusText.text = '${name[0]} is guarding.';
							characterGuarding.set('${name[0]}', true);
							character.color = FlxColor.WHITE;
							FlxTween.color(character, 1, character.color, 0xFF444444, {ease: FlxEase.smootherStepInOut});
							new FlxTimer().start(2, tmr -> nextTurn());
					}

					@:privateAccess battleUI.battleList.focusedMenu = battleUI.battleList;
				}
			}
		}
	}

	function popUpText(target:String, amount:Int, color:FlxColor = FlxColor.RED)
	{
		var healthText = new Text(0, 0, 0, '$amount', 48);
		healthText.color = color;
		var pos = characters.get(target).getMidpoint();
		pos.x += FlxG.random.int(-50, 50);
		pos.y += FlxG.random.int(-25, 25);
		healthText.setPosition(pos.x, pos.y);
		add(healthText);

		FlxTween.tween(healthText, {y: healthText.y - 100}, 1.25);
		FlxTween.tween(healthText, {'alpha': 0}, .5, {startDelay: .75, ease: FlxEase.smootherStepIn, onComplete: twn -> remove(healthText)});
	}

	/**
	 * @return returns if the character is still alive, true is alive
	 */
	function hurt(target:String, ?amount:Int, ?min:Int, ?max:Int):Bool
	{
		trace('$target stats ${characterStats.get(target)}');
		var amt = amount != null ? amount : FlxG.random.int(min, max);

		var maxStart = characterStats.get(target).maxHealth == characterStats.get(target).health;

		characterStats.get(target).health -= amt;
		if (characterStats.get(target).health <= 0)
		{
			characterStats.get(target).health = 0;
			battleUI.charactersAlive.set(target, false);

			if (maxStart)
				achievements.unlock('Strong Man');

			switch (target.split(' ')[0])
			{
				case 'Slime':
					FlxG.save.data.slimeKills++;

				case 'Skeleton':
					FlxG.save.data.skeletonKills++;

				case 'Boss':
					FlxG.save.data.bossKills++;
			}
			FlxG.save.flush();

			if (FlxG.save.data.slimeKills >= 15)
				achievements.unlock('Slime Slaughterer');
			if (FlxG.save.data.skeletonKills >= 15)
				achievements.unlock('Skeleton Slayer');
			if (FlxG.save.data.bossKills >= 1)
				achievements.unlock('Wizworld Champion');
		}

		var c = FlxColor.RED;
		if (amt < 0)
			c = FlxColor.LIME;

		popUpText(target, Std.int(Math.abs(amt)), c);

		return characterStats.get(target).health > 0;
	}

	function nextTurn()
	{
		battleUI.target = null;
		battleUI.action = null;
		var turn = turnOrder.shift();
		turnOrder.push(turn);

		if (!battleUI.charactersAlive.get(turn))
		{
			nextTurn();
			return;
		}

		if (!battleUI.charactersAlive.get('Neko') && !battleUI.charactersAlive.get('Melvin'))
		{
			battleUI.statusText.text = 'Your party is dead! You lose...';
			new FlxTimer().start(3, tmr ->
			{
				music.fadeOut(1, 0);
				subCam.fade(FlxColor.BLACK, 1, false, () -> FlxG.switchState(new MenuState()));
			});
			return;
		}

		var enemiesAllDead:Bool = true;
		var fightingBoss:Bool = false;
		for (character in battleUI.charactersAlive.keys())
		{
			if (character == 'Neko' || character == 'Melvin')
				continue;
			if (character == 'Boss 1')
				fightingBoss = true;

			if (battleUI.charactersAlive.get(character))
			{
				enemiesAllDead = false;
				break;
			}
		}

		if (enemiesAllDead)
		{
			if (fightingBoss)
			{
				battleUI.statusText.text = 'You have defeated the final boss!';
				new FlxTimer().start(3, tmr ->
				{
					music.fadeOut(1, 0);
					subCam.fade(FlxColor.BLACK, 1, false, () -> FlxG.switchState(new ThanksForPlaying()));
				});
				return;
			}
			battleUI.statusText.text = 'You win the battle!';
			new FlxTimer().start(3, tmr ->
			{
				music.fadeOut(1, 0, twn ->
				{
					collidedEnemy.kill();
					close();
				});
			});
			return;
		}
		// name[0] is the actual name and name[1] is the enemy id
		var name = turn.split(' ');
		switch (name[0])
		{
			case 'Slime' | 'Skeleton' | 'Boss':
				playerTurn = false;
				battleUI.statusText.text = '${name[0]}\'s Turn';
				new FlxTimer().start(1, tmr ->
				{
					var s = characters.get('${name[0]} ${name[1]}');

					var targets = [];
					if (battleUI.charactersAlive.get('Neko'))
						targets.push('Neko');
					if (battleUI.charactersAlive.get('Melvin'))
						targets.push('Melvin');
					var t = FlxG.random.getObject(targets);
					var target = characters.get(t);

					var oldPos = s.getPosition();
					FlxTween.tween(s, {x: target.x + target.width - s.width / (t == 'Melvin' ? 1.5 : 2.75), y: target.y + target.height / 2 - s.height / 2},
						1, {
							ease: FlxEase.smootherStepInOut,
							onComplete: twn ->
							{
								new FlxTimer().start(.5, tmr ->
								{
									battleUI.statusText.text = '${name[0]} attacks $t!';
									s.animation.play('attack');
									target.animation.play('hurt');
									Sound.play('hurt');
									var damage = FlxG.random.int(10, 20);
									if (name[0] == 'Boss')
										damage *= 3;

									if (characterGuarding.get(t))
										damage = Math.floor(damage / 3);
									hurt(t, damage);
									subCam.shake(.01, .15);
									FlxTween.tween(s, {x: s.x - 30}, .25, {ease: FlxEase.backOut});
									new FlxTimer().start(.5, tmr ->
									{
										s.animation.play('idle');
										target.animation.play('idle');
										if (!battleUI.charactersAlive.get(t))
											target.animation.play('died');
										FlxTween.tween(s, {x: oldPos.x, y: oldPos.y}, 1,
											{ease: FlxEase.smootherStepInOut, startDelay: .25, onComplete: twn -> nextTurn()});
									});
								});
							}
						});
				});

			case 'Neko' | 'Melvin':
				playerTurn = true;
				battleUI.statusText.text = 'What do you want ${name[0]} to do?';
				battleUI.addSpells(name[0]);

				if (characterGuarding.exists(name[0]))
					if (characterGuarding.get(name[0]))
					{
						characterGuarding.set(name[0], false);
						FlxTween.color(characters.get(name[0]), 1, characters.get(name[0]).color, FlxColor.WHITE, {ease: FlxEase.smootherStepInOut});
					}
		}
	}
}
