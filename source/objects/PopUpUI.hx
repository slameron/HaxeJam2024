package objects;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.tweens.misc.VarTween;
import openfl.geom.Rectangle;

class PopUpUI extends FlxUI9SliceSprite
{
	public var text:Text;

	var prompt:Text;

	public static var popups:Array<PopUpUI> = [];

	public var focused:Bool = true;

	var controls(get, never):Controls;

	function get_controls()
		return Init.controls;

	var cam:FlxCamera;

	var tween:FlxTween;
	var twnFinish:Bool = false;

	var closeTween:FlxTween;
	var closeFinish:Bool = false;

	var members:Array<FlxObject> = [];

	var dismiss:Bool = true;
	var dismissBind:String;
	var dismissCallback:() -> Void;
	var dismissPrompt:String;

	function add(object:FlxObject)
	{
		if (members.contains(object))
			return;

		members.push(object);
	}

	/**
	 * Make a new pop-up text. If there is already a pop up on the screen, the new one will come up after the first is closed.
	 * @param displayText The text you want the pop up to display.
	 * @param dismiss Whether or not you can press your accept key to close the popup. If false, make sure to advance it manually.
	 * @param dismissBind The control the user will press to advance/dimiss the popup. Defaults to `menu_accept`.
	 * @param dismissPrompt Prompt the user what will happen after advancing the prompt. If left null, it will default to `continue/dismiss`. For example, `close` will result in the popup saying `Press (button prompt) to close`.
	 * @param dismissCallback Callback that runs when the user dismisses the prompt and the animation finishes.
	 */
	override public function new(displayText:String, dismiss:Bool = true, dismissBind:String = 'menu_accept', ?dismissPrompt:String,
			?dismissCallback:() -> Void)
	{
		this.dismissBind = dismissBind;
		text = new Text(0, 0, 0, displayText, Std.int((48 * FlxG.height) / 720));
		if (text.width > FlxG.width / 2)
			text.fieldWidth = FlxG.width / 2;

		if (dismiss)
		{
			var daPrompt = controls.lastInput == 'keyboard' ? controls.getPrompt(dismissBind).keyboard : controls.getPrompt(dismissBind).controller;
			prompt = new Text(0, 0, 0, 'Press ${daPrompt.toUpperCase()} to ${dismissPrompt != null ? dismissPrompt : 'continue'}',
				Std.int((32 * FlxG.height) / 720));
			prompt.alpha = .8;
		}

		var daWidth = dismiss ? prompt.width > text.width ? prompt.width : text.width : text.width;
		var daHeight = dismiss ? text.height + prompt.height : text.height;

		super(0, 0, 'assets/images/UI9SLICE.png', new Rectangle(0, 0, Math.ceil(daWidth + 100), Math.ceil(daHeight + 50)), [10, 10, 20, 20]);

		screenCenter();
		text.screenCenter(X);
		text.alignment = CENTER;
		text.y = y + 20;
		add(text);
		if (dismiss)
		{
			add(prompt);
			prompt.screenCenter(X);
			prompt.y = y + height - prompt.height - 20;
		}

		var yDiff = text.y - y;
		text.origin.y = height / 2 - yDiff;
		if (dismiss)
		{
			yDiff = prompt.y - y;
			prompt.origin.y = height / 2 - yDiff;
		}

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		cam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(cam, false);

		cameras = [cam];
		text.cameras = [cam];
		if (dismiss)
			prompt.cameras = [cam];

		if (popups.length > 0)
			focused = false;

		scale.set(0, 0);
		text.scale.set(0, 0);
		if (dismiss)
			prompt.scale.set(0, 0);

		tween = FlxTween.tween(this.scale, {x: 1, y: 1}, .25, {ease: FlxEase.smootherStepOut, onComplete: twn -> twnFinish = true});
		tween.active = false;

		popups.push(this);
		this.dismiss = dismiss;
		this.dismissCallback = dismissCallback;
		this.dismissPrompt = dismissPrompt;
	}

	var waitTimer:Float = 0;

	override public function update(elapsed:Float)
	{
		if (dismiss)
		{
			var daPrompt = controls.lastInput == 'keyboard' ? controls.getPrompt(dismissBind).keyboard : controls.getPrompt(dismissBind).controller;
			prompt.text = 'Press ${daPrompt.toUpperCase()} to ${dismissPrompt != null ? dismissPrompt : popups.length > 1 ? 'continue' : 'dismiss'}';
			var yDiff = prompt.y - y;
			prompt.origin.y = height / 2 - yDiff;
		}

		if (!focused || (waitTimer += elapsed) < .25)
		{
			FlxG.watch.addQuick('return', 'NoFocus');
			return;
		}

		super.update(elapsed);
		if (!tween.active)
			tween.start();

		if (dismiss)
		{
			var mobileDismissed:Bool = false;
			switch (dismissBind)
			{
				case 'menu_accept':
					if (controls.virtualPad?.buttonAccept?.justPressed)
						mobileDismissed = true;
				case 'menu_back':
					if (controls.virtualPad?.buttonBack?.justPressed)
						mobileDismissed = true;
				default:
					if (controls.virtualPad?.buttonAccept?.justPressed)
						mobileDismissed = true;
			}
			if (controls.justPressed(dismissBind) || (FlxG.onMobile && mobileDismissed))
			{
				dismissed = true;
				advance();
			}
		}

		if (bufferAdvance)
			advance();

		for (i in members)
			if (i.active)
				i.update(elapsed);
	}

	var bufferAdvance:Bool = false;
	var onComplete:() -> Void = null;
	var dismissed:Bool = false;

	public function advance(?onComplete:() -> Void)
	{
		bufferAdvance = true;
		if (onComplete != null)
			this.onComplete = onComplete;

		if (tween != null)
			if (tween.active && !twnFinish)
			{
				FlxG.watch.addQuick('return', 'FirstTween');
				return;
			}
		if (closeTween != null)
			if (closeTween.active && !closeFinish)
			{
				FlxG.watch.addQuick('return', 'CloseTween');
				return;
			}
		bufferAdvance = false;
		closeTween = FlxTween.tween(this.scale, {x: 0, y: 0}, .25, {ease: FlxEase.smootherStepIn, onComplete: twn -> closeFinish = true});

		FlxTween.tween(text.scale, {x: 0, y: 0}, .25, {
			ease: FlxEase.smootherStepIn,
			onComplete: twn ->
			{
				if (this.onComplete != null && !dismissed)
					this.onComplete();
				if (this.dismissCallback != null && dismissed)
					this.dismissCallback();
				popups.remove(this);
				if (popups[0] != null)
					popups[0].focused = true;

				destroy();
			}
		});
	}

	override public function draw()
	{
		if (!focused)
			return;

		super.draw();

		for (i in members)
			if (i.visible)
			{
				if (Std.isOfType(i, FlxSprite))
					cast(i, FlxSprite).scale.set(scale.x, scale.y);
				i.draw();
			}
	}

	override public function destroy()
	{
		super.destroy();
		text.destroy();
		text = null;

		FlxG.cameras.remove(cam);
		cam = null;
	}
}
