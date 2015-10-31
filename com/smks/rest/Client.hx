package restclient;

import haxe.Http;
import haxe.io.BytesOutput;

/**
 * @author TABIV
 * @author Shaun Stone
 */
class RestClient
{
	// HTTP Verbs
    private static inline var TYPE_GET = 'GET';
    private static inline var TYPE_POST = 'POST';

	/**
	 * 
	 * @param url
	 * @param onData
	 * @param parameters
	 * @param String > = null
	 * @param onError
	 */
    public static function postAsync(url:String, onData:String->Void = null, parameters:Map < String, String > = null, onError:String->Void = null):Void
    {
        var client = RestClient.buildHttpRequest(
            url,
            parameters,
            true,
            onData,
            onError);
        client.request(true);
    }
    
    // 
    #if !flash
	/**
	 * No synchronous requests/sockets on Flash
	 * 
	 * @param url
	 * @param parameters
	 * @param String> = null
	 * @param onError
	 * @return
	 */
    public static function post(url:String, parameters:Map<String, String> = null, onError:String->Void = null):String
    {
        var result:String;
        var http = RestClient.buildHttpRequest(
            url,
            parameters,
            false,
            function(data:String)
            {
                result = data;
            },
            onError
        );

        // Use the existing http.request only if sys isn't present
        #if sys
            return makeSyncRequest(http, RestClient.TYPE_POST);
        #else
            http.request(true);
            return result;
        #end
    }
    #end
    
	/**
	 * 
	 * @param url
	 * @param onData
	 * @param parameters
	 * @param String > = null
	 * @param onError
	 */
    public static function getAsync(url:String, onData:String->Void = null, parameters:Map < String, String > = null, onError:String->Void = null):Void
    {
        var http = RestClient.buildHttpRequest(
            url,
            parameters,
            true,
            onData,
            onError
        );
        http.request(false);
    }
    
    // No synchronous requests/sockets on Flash
    #if !flash
	/**
	 * 
	 * @param url
	 * @param parameters
	 * @param String> = null
	 * @param onError
	 * @return
	 */
    public static function get(url:String, parameters:Map<String, String> = null, onError:String->Void = null):String
    {
        var result:String;

        var http = RestClient.buildHttpRequest(
            url,
            parameters,
            false,
            function(data:String)
            {
                result = data;
            },
            onError
        );
        
        // Use the existing http.request only if sys isn't present
        #if sys
            return makeSyncRequest(http, RestClient.TYPE_GET);
        #else
            http.request(false);
            return result;
        #end
    }
    #end
    
    #if sys
	/**
	 * 
	 * @param http
	 * @param method
	 * @return
	 */
    private static function makeSyncRequest(http:Http, method:String = RestClient.TYPE_GET):String
    {
        // TODO: SSL for HTTPS URLs
        var output = new BytesOutput();
        http.customRequest(false, output, null, method);
        return output.getBytes()
            .toString();
    }
    #end
    
	/**
	 * 
	 * @param url
	 * @param parameters
	 * @param String = null
	 * @param async
	 * @param onData
	 * @param onError
	 * @return
	 */
    private static function buildHttpRequest(url:String, parameters:Map<String, String> = null, async:Bool = false, onData:String->Void = null, onError:String->Void = null):Http
    {
        var http = new Http(url);
            
        #if js
        http.async = async;
        #end
        
        if (onError != null) {
            http.onError = onError;
        }
        
        if (onData != null) {
            http.onData = onData;
        }
        
        if (parameters != null) {
            for (x in parameters.keys()) {
                http.setParameter(x, parameters.get(x));
            }
        }
        
        #if flash
        // Disable caching
        http.setParameter("_nocache", Std.string(Date.now().getTime()));
        #end
        
        return http;
    }
}