package objects;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import openfl.geom.Rectangle;

class BattleUI extends FlxTypedGroup<FlxBasic>
{
	var controls(get, never):Controls;

	function get_controls()
		return Init.controls;

	public var ready:Bool = false;
	public var statusText:Text;
	public var bg:FlxUI9SliceSprite;
	public var enemies:Array<String>;
	public var charactersAlive:Map<String, Bool> = [];
	public var action:String;
	public var target:String;
	public var onFlee:() -> Void;

	var battleList:SelectionList;

	/**
	 * like set position but i want members to retain their relative position
	 */
	public function adjustPosition(x:Float, y:Float)
	{
		for (member in members)
		{
			if (Std.is(member, SelectionList))
			{
				var m = cast(member, SelectionList);
				m.forEach(t -> t.y += y);
				m.topBound += y;
				m.bottomBound += y;
				@:privateAccess m._defY += y;
			}
			else
			{
				var m = cast(member, FlxObject);
				m.x += x;
				m.y += y;
			}
		}
	}

	override public function new(x:Float, y:Float, onFlee:() -> Void)
	{
		super();

		this.onFlee = onFlee;
		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/UI9SLICE.png',
			new Rectangle(0, 0, Math.ceil(FlxG.width - FlxG.width / 4), Math.ceil(FlxG.height / 3)), [10, 10, 20, 20]);
		add(bg);

		statusText = new Text(0, 10, bg.width, 'Prepare for battle!', 32);
		statusText.alignment = CENTER;
		add(statusText);

		var defaultY = statusText.y + statusText.height + 5;
		var spacing = statusText.height + 20;
		var topBound = defaultY;
		var bottomBound = bg.height - 5;

		battleList = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
		battleList.addCallback('Spells', f -> trace('cast magic'));
		battleList.addCallback('Attack', f -> trace('melee attack'));
		battleList.addCallback('Guard', f ->
		{
			action = 'Guard';
			target = 'Melvin';
		});
		battleList.addCallback('Run', f ->
		{
			if (enemies.contains('Boss 1'))
			{
				action = 'BossFlee';
				target = 'Melvin';
			}
			else if (FlxG.random.bool(75))
			{
				action = 'Flee';
				target = 'Melvin';
			}
			else
			{
				action = 'FailEscape';
				target = 'Melvin';
			}
		});

		battleList.maxScroll = 1;

		add(battleList);
	}

	var healths:Map<String, Text> = [];

	public function addHealthTexts()
	{
		var nekoHealth = new Text(0, 0, 0, 'Neko\'s HP: 150 / 150', 24);
		var melvinHealth = new Text(0, 0, 0, 'Melvin\'s HP: 100 / 100', 24);

		var space = bg.height / 2;
		var startingy = bg.y + bg.height / 2 - space / 2;
		space /= 2;
		melvinHealth.setPosition(bg.x + 30, startingy + space / 2 - melvinHealth.height / 2);
		nekoHealth.setPosition(bg.x + 30, startingy + space + space / 2 - nekoHealth.height / 2);

		add(melvinHealth);
		add(nekoHealth);

		healths.set('Melvin', melvinHealth);
		healths.set('Neko', nekoHealth);

		for (i in 0...enemies.length)
		{
			var enemyHealth = new Text(0, 0, 0, '${enemies[i]}\'s HP: 0 / 0', 24);
			var space = bg.height / 2;
			var startingy = bg.y + bg.height / 2 - space / 2;
			space /= enemies.length;

			enemyHealth.setPosition(bg.x + bg.width - enemyHealth.width - 30, startingy + (space * i) + space / 2 - enemyHealth.height / 2);
			add(enemyHealth);
			healths.set(enemies[i], enemyHealth);
		}
	}

	public function addSpells(character:String)
	{
		var defaultY:Float;
		var spacing:Float;
		var topBound:Float;
		var bottomBound:Float;
		@:privateAccess {
			defaultY = battleList._defY;
			spacing = battleList._spacing;
			topBound = battleList.topBound;
			bottomBound = battleList.bottomBound;
		}
		var spellsList = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
		switch (character)
		{
			case 'Neko':
				var fireball = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
				fireball.maxScroll = 1;
				for (i in 0...enemies.length)
				{
					if (charactersAlive.get(enemies[i]))
						fireball.addCallback(enemies[i], f ->
						{
							target = enemies[i];
							trace('setting target to $target');
						});
				}
				spellsList.addSubmenu('Fireball', fireball, () ->
				{
					statusText.text = 'Who would you like to cast a fireball upon?';
					action = 'Fireball';
				}, () ->
					{
						statusText.text = 'What magic spell would you like to cast?';
						action = null;
					});
			case 'Melvin':
				var shockwave = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
				shockwave.maxScroll = 1;
				for (i in 0...enemies.length)
				{
					if (charactersAlive.get(enemies[i]))
						shockwave.addCallback(enemies[i], f ->
						{
							target = enemies[i];
							trace('setting target to $target');
						});
				}
				spellsList.addSubmenu('Shockwave', shockwave, () ->
				{
					statusText.text = 'Who would you like to cast a shockwave upon?';
					action = 'Shockwave';
				}, () ->
					{
						action = null;
						statusText.text = 'What magic spell would you like to cast?';
					});
		}
		spellsList.addCallback('Heal', f -> trace('heal!'));
		var heal = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
		heal.maxScroll = 1;
		if (charactersAlive.get('Melvin'))
			heal.addCallback('Melvin', f -> target = 'Melvin');
		if (charactersAlive.get('Neko'))
			heal.addCallback('Neko', f -> target = 'Neko');

		spellsList.addSubmenu('Heal', heal, () ->
		{
			statusText.text = 'Who would you like to heal?';
			action = 'Heal';
		}, () ->
			{
				statusText.text = 'What magic spell would you like to cast?';
				action = null;
			});

		var attack = new SelectionList(defaultY, spacing, topBound, bottomBound, null, 48);
		attack.maxScroll = 1;
		for (i in 0...enemies.length)
		{
			if (charactersAlive.get(enemies[i]))
				attack.addCallback(enemies[i], f ->
				{
					target = enemies[i];
					trace('setting target to $target');
				});
		}

		var curText = statusText.text;
		battleList.addSubmenu('Spells', spellsList, () -> statusText.text = 'What magic spell would you like to cast?', () -> statusText.text = curText);
		battleList.addSubmenu('Attack', attack, () ->
		{
			statusText.text = 'Who would you like to attack?';
			action = 'Attack';
		}, () ->
			{
				statusText.text = curText;
				action = null;
			});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		battleList.focusedMenu.forEach(spr ->
		{
			spr.color = FlxColor.WHITE;
		});
		for (character in charactersAlive.keys())
		{
			if (healths.exists(character))
				healths.get(character)
					.text = '${character}\'s HP: ${cast (FlxG.state.subState, BattleSubstate).characterStats.get(character).health} / ${cast (FlxG.state.subState, BattleSubstate).characterStats.get(character).maxHealth}';

			if (character != 'Neko' && character != 'Melvin')
				healths.get(character).x = bg.x + bg.width - healths.get(character).width - 30;
		}
		if (!ready || selected)
			return;

		if (controls.justPressed('menu_up') || (FlxG.onMobile && controls.virtualPad?.buttonUp?.justPressed))
			change(-1);
		if (controls.justPressed('menu_down') || (FlxG.onMobile && controls.virtualPad?.buttonDown?.justPressed))
			change(1);

		if (controls.justPressed('menu_back') || (FlxG.onMobile && controls.virtualPad?.buttonBack?.justPressed))
			if (battleList.focusedMenu.options.contains('Back'))
				battleList.focusedMenu.select(0, 'Back');

		battleList.focusedMenu.forEach(spr ->
		{
			if (spr.ID == battleList.focusedMenu.curSelected)
				spr.color = 0xFFffcc26;
		});
		if (controls.justPressed('menu_accept') || (FlxG.onMobile && controls.virtualPad?.buttonAccept?.justPressed))
			battleList.focusedMenu.select();
		if (controls.justPressed('menu_left') || (FlxG.onMobile && controls.virtualPad?.buttonLeft?.justPressed))
			battleList.focusedMenu.select(-1);
		if (controls.justPressed('menu_right') || (FlxG.onMobile && controls.virtualPad?.buttonRight?.justPressed))
			battleList.focusedMenu.select(1);
	}

	var selected:Bool = false;

	function retSel(sel:Int):Int
		return Std.int(FlxMath.bound(sel, 0, battleList.focusedMenu.length - 1));

	function change(by:Int = 0)
	{
		battleList.focusedMenu.curSelected = retSel(battleList.focusedMenu.curSelected + by);
		battleList.focusedMenu.scroll(by);
		Sound.play('menuChange');
	}
}
