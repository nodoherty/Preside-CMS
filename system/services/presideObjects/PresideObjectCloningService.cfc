/**
 * Service that provides functionality around cloning preside
 * object records.
 *
 * @presideService true
 * @singleton      true
 * @autodoc        true
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	/**
	 * Clones a record for the given object, record ID
	 * and supporting data
	 *
	 * @autodoc    true
	 * @objectName Name of the object whose record you wish to clone
	 * @recordId   ID of the record to clone
	 * @data       Data to overwrite any data for the existing record
	 *
	 */
	public string function cloneRecord(
		  required string objectName
		, required string recordId
		, required struct data
	) {
		if ( !isCloneable( objectName=arguments.objectName ) ) {
			throw( type="preside.cloning.not.possible", message="The object, [#arguments.objectName#], is not cloneable." );
		}

		var customHandler = getCloneHandler( objectName=arguments.objectName );
		if ( Len( Trim( customHandler ) ) ) {
			var result = $getColdbox().runEvent(
				  event          = customHandler
				, private        = true
				, prePostExempt  = true
				, eventArguments = { objectName=arguments.objectName, recordId=arguments.recordId, data=arguments.data }
			);

			return IsSimpleValue( result ?: {} ) ? result : "";
		}

		var originalRecord = $getPresideObjectService().selectData(
			  objectName = arguments.objectName
			, id         = arguments.recordId
		);
		if ( !originalRecord.recordCount ) {
			throw( type="preside.clone.record.not.found", message="Clone failed. Object record [#arguments.objectName#: #arguments.recordId#] was not found." );
		}

		return "";
	}


	/**
	 * Returns an array of fieldnames for properties that are clonable for the
	 * given object.
	 *
	 * @autodoc true
	 * @objectName Name of the object whose list of fields you wish to get
	 *
	 */
	public array function listCloneableFields( required string objectName ) {
		var cloneable         = [];
		var poService         = $getPresideObjectService();
		var props             = poService.getObjectProperties( objectName=objectName );
		var idField           = poService.getIdField( objectName=objectName );
		var dateCreatedField  = poService.getDateCreatedField( objectName=objectName );
		var dateModifiedField = poService.getDateModifiedField( objectName=objectName );
		var ignoreFields      = [ idField, dateCreatedField, dateModifiedField ];

		for( var propName in props ) {
			var prop        = props[ propName ];
			var isCloneable = prop.cloneable ?: "";

			if ( IsBoolean( isCloneable ) && !isCloneable ) {
				continue;
			}

			if ( ignoreFields.findNoCase( propName ) ) {
				continue;
			}

			if ( Len( Trim( prop.formula ?: "" ) ) ) {
				continue;
			}

			if ( !IsBoolean( isCloneable ) ) {
				if ( Len( Trim( prop.uniqueIndexes ?: "" ) ) ) {
					continue;
				}

				if ( ( prop.relationship ?: "" ) == "one-to-many" ) {
					continue;
				}
			}

			cloneable.append( propName );
		}

		return cloneable;
	}

	/**
	 * Returns whether or not the given object
	 * is cloneable
	 *
	 * @autodoc    true
	 * @objectName Name of the object to check
	 */
	public boolean function isCloneable( required string objectName ) {
		var cloneable = $getPresideObjectService().getObjectAttribute(
			  objectName    = arguments.objectName
			, attributeName = "cloneable"
		);

		if ( IsBoolean( cloneable ) && !cloneable ) {
			return false;
		}

		return listCloneableFields( arguments.objectName ).len() > 0;
	}

	/**
	 * Returns handler event used to clone an object
	 * record, or empty string if no custom handler
	 * exists.
	 *
	 * @autodoc true
	 * @objectName Name of the object whose clone handler you wish to get
	 *
	 */
	public string function getCloneHandler( required string objectName ) {
		return $getPresideObjectService().getObjectAttribute(
			  objectName    = arguments.objectName
			, attributeName = "cloneHandler"
		);
	}

// PRIVATE HELPERS

// GETTERS AND SETTERS

}