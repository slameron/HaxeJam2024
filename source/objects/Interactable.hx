package objects;

class Interactable extends FlxSprite
{
	public var onInteract:() -> Void;
	public var canInteract:Bool = true;
	public var hovered:Bool = false;
	public var canHover:Bool = false;

	var prompt:ButtonPrompt;
	var interact:String;

	override public function new(x:Float, y:Float, interactPrompt:String = 'interact', asset:String, wh:Int)
	{
		super(x, y);
		interact = interactPrompt;

		loadGraphic(asset, true, wh, wh);

		prompt = new ButtonPrompt(Std.int(x), Std.int(y), Init.controls.getPrompt(interactPrompt), 1);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		prompt.update(elapsed);

		if (hovered && Init.controls.justPressed(interact) && canInteract && canHover)
			if (onInteract != null)
				onInteract();
	}

	override public function draw()
	{
		if (hovered && canHover)
		{
			FlxG.watch.addQuick('trying to draw', true);
			prompt.setPosition(x + width / 2 - prompt.w / 2, y - prompt.h - 5);
			prompt.draw();
		}
		super.draw();
	}
}
