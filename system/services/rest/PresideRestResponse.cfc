/**
 * Object to represent a REST response. Used in REST requests (see [[preside-rest-platform]]).
 *
 * @autodoc true
 */
component accessors=true displayName="Preside REST Response" {

	property name="data"         type="any";
	property name="mimeType"     type="string"  default="application/json";
	property name="renderer"     type="string"  default="json";
	property name="statusCode"   type="numeric" default=200;
	property name="statusText"   type="string"  default="";
	property name="headers"      type="struct";
	property name="finished"     type="boolean" default=false;

	/**
	 * Returns all response properties as a simple CFML struct
	 *
	 * @autodoc true
	 */
	public struct function getMemento() {
		return {
			  data         = getData()
			, mimeType     = getMimeType()
			, renderer     = getRenderer()
			, statusCode   = getStatusCode()
			, statusText   = getStatusText()
			, headers      = getHeaders()
			, finished     = getFinished()
		};
	}

	/**
	 * Sets the status of the response and returns
	 * reference to self so that methods can be chained
	 * allows setting of both code and text for the response.
	 *
	 * @code.hint Numeric status code to set on the response
	 * @text.hint Free text status message to return with the response
	 * @autodoc true
	 */
	public any function setStatus( numeric code, string text ) {
		if ( arguments.keyExists( "code" ) ) {
			variables.statusCode = arguments.code;
		}

		if ( arguments.keyExists( "text" ) ) {
			variables.statusText = arguments.text;
		}

		return this;
	}

	/**
	 * Sets headers on the rest response object. Can be called multiple
	 * times to build a greater collection of headers
	 *
	 * @headers.hint Structure containing headers where struct keys are header names and values are corresponding header values
	 * @autodoc true
	 */
	public any function setHeaders( required struct headers ) {
		variables.headers = variables.headers ?: {};
		variables.headers.append( arguments.headers )

		return this;
	}

	/**
	 * Adds an individual header to the headers in the response
	 *
	 * @name.hint  the name of the header
	 * @value.hint the value of the header
	 * @autodoc
	 */
	public any function setHeader( required string name, required string value ) {
		variables.headers = variables.headers ?: {};
		variables.headers[ arguments.name ] = arguments.value;

		return;
	}

	/**
	 * Sets the data of the response. This data will later be converted into
	 * whichever response format is specified for the request (json by default)
	 *
	 * @data.hint the data to set
	 * @autodoc true
	 *
	 */
	public any function setData( required any data ) {
		variables.data = arguments.data;

		return this;
	}

	/**
	 * Sets the data of the response to NULL which instructs the response processor
	 * to return an empty body
	 *
	 * @autodoc true
	 *
	 */
	public any function noData() {
		variables.data = NullValue();
		setRenderer( "plain" );
		setMimeType( "text/plain" );

		return this;
	}

	/**
	 * Sets the mime type of the response and returns
	 * reference to self so that methods can be chained
	 *
	 * @mimetype.hint mime type of the response, e.g. 'application/json'
	 * @autodoc true
	 */
	public any function setMimeType( required string mimeType ) {
		variables.mimeType = arguments.mimeType;

		return this;
	}

	/**
	 * Sets the renderer of the response and returns
	 * reference to self so that methods can be chained.
	 *
	 * @renderer.hint renderer for the response, e.g. 'json'
	 * @autodoc true
	 */
	public any function setRenderer( required string renderer ) {
		variables.renderer = arguments.renderer;

		return this;
	}

	/**
	 * Sets data, statuses and headers based on common arguments
	 * for errors
	 *
	 * @autodoc true
	 */
	public any function setError(
		  string  type      = "Unspecified error"
		, numeric errorCode = 500
		, string  message   = "An unhandled exception occurred within the REST API"
		, string  detail    = ""
	) {
		noData().setStatus( arguments.errorCode, arguments.type );

		if ( arguments.message.len() ) {
			setHeader( "X-REST-ERROR-MESSAGE", arguments.message );
		}
		if ( arguments.detail.len() ) {
			setHeader( "X-REST-ERROR-DETAIL", arguments.detail );
		}
	}

	/**
	 * Flags the response as finished so that no further processing should
	 * be made by handling code.
	 *
	 * @autodoc true
	 */
	public any function finish() {
		setFinished( true );
		return this;
	}

	/**
	 * Returns whether or not the response is finished with
	 *
	 * @autodoc true
	 *
	 */
	public boolean function isFinished() {
		return getFinished();
	}
}