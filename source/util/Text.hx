package util;

class Text extends FlxText
{
	public var originalText:String;

	var labelText:Text;
	var labelTop:Bool;

	public var child:FlxSprite;
	public var childOffset:FlxPoint;
	public var bound:FlxPoint;

	override public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true, customFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		originalText = Text;
		if (customFont)
			font = 'assets/fonts/grapesoda-by-jeti-with-playstation-icons.ttf';

		setBorderStyle(SHADOW, FlxColor.BLACK, Size < 8 ? Size / 4 : Size / 8, 1);

		#if web
		var htmlDiff:Int = Math.floor(height - size) - 4;
		height -= htmlDiff;
		offset.y = htmlDiff;
		#end

		setPosition(Std.int(x), Std.int(y)); // Round the position to prevent weird tearing
	}

	public function addLabel(text:String, size:Int = 8, top:Bool = true, screenCenter:Bool = false)
	{
		labelText = new Text(0, 0, screenCenter ? FlxG.width : 0, text, size);
		labelText.alignment = CENTER;
		labelText.color = FlxColor.fromRGB(200, 200, 200);
		labelTop = top;
	}

	public function removeLabel()
	{
		labelText.destroy();
		labelText = null;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (labelText != null)
		{
			var yOff = labelText.size - ((8 * FlxG.height) / 720);
			labelText.setPosition(x, labelTop ? y - labelText.height + yOff : y + height - yOff);
			labelText.alpha = alpha;
			var topBound:Float = (343 * FlxG.height) / 720;
			var bottomBound:Float = (630 * FlxG.height) / 720;

			if (bound != null)
			{
				topBound = bound.x;
				bottomBound = bound.y;
			}
			if (labelText.clipRect != null)
			{
				labelText.clipRect.put();
				labelText.clipRect = null;
			}
			if (labelText.y < topBound)
			{
				var yDiff = topBound - labelText.y;
				labelText.clipRect = FlxRect.get(0, yDiff, labelText.width, labelText.height - yDiff);
			}
			else if (labelText.y + labelText.height > bottomBound)
			{
				var yDiff = labelText.y + labelText.height - bottomBound;
				labelText.clipRect = FlxRect.get(0, 0, labelText.width, labelText.height - yDiff);
			}
		}

		if (child != null && childOffset != null)
		{
			child.alpha = alpha;
			child.update(elapsed);
			child.setPosition(x + childOffset.x, y + childOffset.y);
			if (childOffset.x == 0 && childOffset.y == 0)
				child.setPosition(x + width + 20, y + height / 2 - child.height / 2);

			var topBound:Float = (343 * FlxG.height) / 720;
			var bottomBound:Float = (630 * FlxG.height) / 720;

			if (bound != null)
			{
				topBound = bound.x;
				bottomBound = bound.y;
			}
			if (child.clipRect != null)
			{
				child.clipRect.put();
				child.clipRect = null;
			}
			if (child.y < topBound)
			{
				var yDiff = topBound - child.y;
				child.clipRect = FlxRect.get(0, yDiff, child.width, child.height - yDiff);
			}
			else if (child.y + child.height > bottomBound)
			{
				var yDiff = child.y + child.height - bottomBound;
				child.clipRect = FlxRect.get(0, 0, child.width, child.height - yDiff);
			}
		}
	}

	override public function draw()
	{
		if (labelText != null && labelText.visible && labelTop)
			labelText.draw();
		if (child != null && child.visible)
			child.draw();
		super.draw();
		if (labelText != null && labelText.visible && !labelTop)
			labelText.draw();
	}
}
