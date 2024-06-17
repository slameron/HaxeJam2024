package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.app.Application;
import lime.utils.Assets;

class MenuState extends DefaultState
{
	var title:FlxTypeText;
	var mainMenu:SelectionList;
	var uparrow:Text;
	var downArrow:Text;

	override public function create()
	{
		super.create();
		var screen = new FlxBackdrop('assets/images/titleBG.png');
		screen.velocity.set(30, 15);
		screen.scale.set(4, 4);
		add(screen);

		if (Sound.menuMusic != null)
		{
			Sound.menuMusic.play();
			Sound.menuMusic.fadeIn(1, Sound.menuMusic.volume, FlxG.save.data.musicVolume * FlxG.save.data.masterVolume);
		}
		else
		{
			Sound.menuMusic = Sound.playMusic('serenity-fato_shadow');
		}

		FlxG.camera.fade(FlxColor.BLACK, 1, true);

		var overlay = new FlxBackdrop('assets/images/titleOverlay.png', Y);
		overlay.scale.set(4, 4);
		overlay.velocity.set(0, 20);
		add(overlay);

		var wizwords = new Text(0, 0, 0, 'Wizworld', 128);

		wizwords.y = (FlxG.height / 2) - wizwords.height - ((30 * FlxG.height) / 720);
		wizwords.screenCenter(X);
		// add(wizwords);
		overlay.x = wizwords.x + wizwords.width / 2 - overlay.width / 2;
		var letterGroup:FlxTypedGroup<Text>;
		letterGroup = new FlxTypedGroup();
		add(letterGroup);
		var letters = wizwords.text.split('');
		for (i in 0...letters.length)
		{
			var letter = new Text(0, 0, 0, letters[i], 128);

			letter.setPosition(letterGroup.members.length == 0 ? wizwords.x : letterGroup.members[letterGroup.members.length - 1].x
				+ letterGroup.members[letterGroup.members.length - 1].width - 4,
				wizwords.y);
			letterGroup.add(letter);
			letter.angle = -5;
			FlxTween.tween(letter, {y: letter.y + 15}, 2, {type: PINGPONG, ease: FlxEase.smootherStepInOut, startDelay: i * .1});
			FlxTween.tween(letter, {angle: 5}, 3, {type: PINGPONG, ease: FlxEase.smootherStepInOut, startDelay: i * .1});
		}

		var defY = wizwords.y + wizwords.height + ((30 * FlxG.height) / 720);
		var spacing = (70 * FlxG.height / 720);
		var topBound = defY;
		var bottomBound = FlxG.height - spacing;

		mainMenu = new SelectionList(defY, spacing, topBound, bottomBound, Application.current.meta.get('title'));
		mainMenu.addCallback('Play', f ->
		{
			selected = true;
			FlxG.camera.fade(FlxColor.BLACK, 1, false, () -> FlxG.switchState(new PlayState('tutorial')), true);
			Sound.menuMusic.fadeOut(1, 0, twn ->
			{
				Sound.menuMusic.stop();
				Sound.menuMusic = null;
			});
		});

		mainMenu.addCallback('Options', f -> trace('Options!'));
		mainMenu.addCallback('Achievements', f -> trace('Achievements!'));
		mainMenu.addCallback('Credits', f -> trace('Credits!'));
		#if FLX_DEBUG
		mainMenu.addCallback('Crash the game', f ->
		{
			var nullobj:FlxSprite = null;
			nullobj.makeGraphic(1, 1);
		});

		mainMenu.addCallback('Test discord message', f ->
		{
			Discord.sendWebhookMessage('Test hiiiiii :3', Keys.crashWebhook, Application.current.meta.get('title'));
		});
		#end
		#if !web
		mainMenu.addCallback('Quit>Are you sure?', f -> Sys.exit(0));
		#end

		// mainMenu.tweenTexts(20, false, .25, .5, .15);
		add(mainMenu);

		// var playMenu = new SelectionList(defY, spacing, topBound, bottomBound, 'Play');
		// playMenu.addCallback('Tutorial', f ->
		// {
		// 	selected = true;
		// 	FlxG.camera.fade(FlxColor.BLACK, 1, false, () -> FlxG.switchState(new PlayState('tutorial')));
		// 	Sound.menuMusic.fadeOut(1, 0);
		// });
		// playMenu.addCallback('Enter the wizworld', f -> {});
		//	mainMenu.addSubmenu('Play', playMenu);

		var optionsMenu = new SelectionList(defY, spacing, topBound, bottomBound, 'Options');
		optionsMenu.addCallback('Fullscreen', myFloat ->
		{
			FlxG.fullscreen = !FlxG.fullscreen;
			FlxG.save.data.fullscreen = FlxG.fullscreen;
			FlxG.save.flush();
		});
		optionsMenu.addCallback('Master Volume', by ->
		{
			FlxG.sound.volume += .1 * by;
			FlxG.sound.volume = FlxMath.bound(FlxG.sound.volume, 0, 1);
			FlxG.save.data.masterVolume = FlxG.sound.volume;
			FlxG.save.flush();

			FlxG.game.soundTray.silent = false;
			FlxG.game.soundTray.show(by > 0, FlxG.save.data.masterVolume, 'MASTER');
		}, true, true).addCallback('Sound Volume', by ->
			{
				FlxG.save.data.soundVolume += .1 * by;
				FlxG.save.data.soundVolume = FlxMath.bound(FlxG.save.data.soundVolume, 0, 1);
				FlxG.save.flush();

				FlxG.game.soundTray.silent = false;
				FlxG.game.soundTray.show(by > 0, FlxG.save.data.soundVolume, 'SOUND');
			}, true, true).addCallback('Music Volume', by ->
			{
				FlxG.save.data.musicVolume += .1 * by;
				FlxG.save.data.musicVolume = FlxMath.bound(FlxG.save.data.musicVolume, 0, 1);
				FlxG.save.flush();

				FlxG.game.soundTray.silent = true;
				FlxG.game.soundTray.show(by > 0, FlxG.save.data.musicVolume, 'MUSIC');
				Sound.menuMusic.volume = FlxG.save.data.musicVolume * FlxG.save.data.masterVolume;
			}, true, true);
		mainMenu.addSubmenu('Options', optionsMenu);

		var achievementsMenu = new SelectionList(defY, spacing * 2, topBound, bottomBound, 'Achievements');
		achievementsMenu.maxScroll = 2;
		for (ach in achievements.achievementsList)
		{
			var achImage = new FlxSprite().loadGraphic(achievements.save.get(ach)
				.unlocked ? achievements.achievements.get(ach)
				.image : 'assets/images/achievements/locked.png');
			achImage.scale.set(.5, .5);
			achImage.updateHitbox();
			achievementsMenu.addText(achievements.save.get(ach)
				.unlocked ? achievements.achievements.get(ach)
				.unlockedDesc : achievements.achievements.get(ach)
				.lockedDesc
					+ ' - LOCKED',
				ach, true, achImage, FlxPoint.get(FlxG.width / 2 - achImage.width / 2, achImage.height + 20));
		}
		mainMenu.addSubmenu('Achievements', achievementsMenu);

		var creditsMenu = new SelectionList(defY, spacing, topBound, bottomBound, 'Credits');
		creditsMenu.addText('Programming by slameron');
		creditsMenu.addText('Concept artwork by ArtistCodyMeyer');
		creditsMenu.addText('Additional artwork by slameron');
		creditsMenu.addText('Music from OpenGameArt');
		creditsMenu.addText('GrapeSoda font by Jeti');
		creditsMenu.addText('Tileset and button prompts from Kenney.nl');
		creditsMenu.addText('Sound effects from Zapsplat and Sfxr');
		creditsMenu.addText('Original version made for the summer HaxeJam 2024');
		creditsMenu.addText('Made in HaxeFlixel');
		mainMenu.addSubmenu('Credits', creditsMenu);

		uparrow = new Text(0, defY, FlxG.width, 'V', Std.int((32 * FlxG.height) / 720));
		uparrow.flipY = true;
		uparrow.alignment = CENTER;
		uparrow.y -= uparrow.height / 2;
		downArrow = new Text(0, bottomBound, FlxG.width, 'V', Std.int((32 * FlxG.height) / 720));
		downArrow.alignment = CENTER;
		downArrow.y -= downArrow.height / 2;
		add(uparrow);
		add(downArrow);

		promptBack = new ButtonPrompt(0, 0, controls.getPrompt('menu_back'), 2, 'Back', 32);
		promptBack.setPosition(FlxG.width - 15 - promptBack.w, FlxG.height - promptBack.height - 5);
		promptAccept = new ButtonPrompt(0, 0, controls.getPrompt('menu_accept'), 2, 'Accept', 32);
		promptAccept.setPosition(promptBack.x - 20 - promptAccept.w, FlxG.height - promptAccept.height - 5);

		var version = Application.current.meta.get('version');

		if (Application.current.meta.get('nightly') != '')
			version += '-${Application.current.meta.get('nightly')}';
		#if FLX_DEBUG
		version += ' - DEBUG : NOT FOR RELEASE';
		#end
		var versionText = new Text(0, 0, 0, 'v$version', 32);
		versionText.setPosition(15, FlxG.height - versionText.height - 5);

		var underline = new FlxSprite().makeGraphic(FlxG.width, Std.int(promptAccept.h + 10), FlxColor.BLACK);
		underline.alpha = .3;
		underline.y = FlxG.height - underline.height;
		add(underline);
		add(promptBack);
		add(promptAccept);
		add(versionText);

		postCreate();
	}

	var promptAccept:ButtonPrompt;

	var promptBack:ButtonPrompt;
	var selected:Bool = false;

	function retSel(sel:Int):Int
		return Std.int(FlxMath.bound(sel, 0, mainMenu.focusedMenu.length - 1));

	function change(by:Int = 0)
	{
		mainMenu.focusedMenu.curSelected = retSel(mainMenu.focusedMenu.curSelected + by);
		mainMenu.focusedMenu.scroll(by);
		Sound.play('menuChange');
	}

	override public function update(elapsed:Float)
	{
		if (transitioning)
			return;
		super.update(elapsed);
		if (shouldRet)
			return;
		promptBack.setPosition(FlxG.width - 15 - promptBack.w, FlxG.height - promptBack.height - 5);
		promptAccept.setPosition(promptBack.x - 20 - promptAccept.w, FlxG.height - promptAccept.height - 5);

		#if FLX_DEBUG
		if (FlxG.keys.justPressed.G)
			achievements.unlock('Sample Achievement 1');
		if (FlxG.keys.justPressed.H)
		{
			FlxG.save.data.achievements = null;
			FlxG.save.flush();
		}
		#end

		if (controls.justPressed('menu_up') || (FlxG.onMobile && controls.virtualPad?.buttonUp?.justPressed))
			change(-1);
		if (controls.justPressed('menu_down') || (FlxG.onMobile && controls.virtualPad?.buttonDown?.justPressed))
			change(1);

		if (controls.justPressed('menu_back') || (FlxG.onMobile && controls.virtualPad?.buttonBack?.justPressed))
			if (mainMenu.focusedMenu.options.contains('Back'))
				mainMenu.focusedMenu.select(0, 'Back');

		mainMenu.focusedMenu.forEach(spr ->
		{
			if (spr.ID == mainMenu.focusedMenu.curSelected)
				spr.color = 0xFFffcc26;
			else
				spr.color = FlxColor.WHITE;
		});
		if (controls.justPressed('menu_accept') && !selected || (FlxG.onMobile && controls.virtualPad?.buttonAccept?.justPressed))
			mainMenu.focusedMenu.select();
		if (controls.justPressed('menu_left') && !selected || (FlxG.onMobile && controls.virtualPad?.buttonLeft?.justPressed))
			mainMenu.focusedMenu.select(-1);
		if (controls.justPressed('menu_right') && !selected || (FlxG.onMobile && controls.virtualPad?.buttonRight?.justPressed))
			mainMenu.focusedMenu.select(1);

		@:privateAccess
		{
			uparrow.visible = mainMenu.focusedMenu.scrollAmount > 0;
			downArrow.visible = mainMenu.focusedMenu.options.length - mainMenu.focusedMenu.scrollAmount > mainMenu.focusedMenu.maxScroll + 1;
		}
	}
}
