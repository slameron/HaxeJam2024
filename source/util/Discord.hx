package util;

#if sys
import Sys.sleep;
#end
#if cpp
import discord_rpc.DiscordRpc;
#end

using StringTools;

class Discord
{
	public static var isInitialized:Bool = false;

	static var startTime:Null<Float> = null;

	public static function sendWebhookMessage(msg:String, webhookKey:String, ?name:String)
	{
		var parameters = {
			username: '${name != null ? '$name ' : ''}Crash Logs',
			content: msg
		};

		var request = new haxe.Http('https://discord.com/api/webhooks/$webhookKey');
		request.setHeader('Content-type', 'application/json');
		request.setPostData(haxe.Json.stringify(parameters));
		request.request(true);
	}
}
