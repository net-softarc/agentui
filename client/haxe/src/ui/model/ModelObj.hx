package ui.model;

import m3.util.ColorProvider;
import m3.util.UidGenerator;
import m3.observable.OSet;
import m3.serialization.Serialization;
import m3.exception.Exception;

import ui.helper.LabelStringParser;

using m3.helper.ArrayHelper;
using m3.helper.OSetHelper;
using m3.helper.StringHelper;
import DateTools;
using StringTools;
using Lambda;

@:rtti
class ModelObj<T> {
	@:isVar 
	@:transient 
	public var uid(get,set): String;

	public function new() {
		this.uid = UidGenerator.create();
	}

	public static function identifier<T>(t: ModelObj<T>): String {
		return t.uid;
	}

	private function get_uid(): String {
		if(this.uid.isBlank()) {
			this.uid = UidGenerator.create();
		}
		return this.uid;
	}

	private function set_uid(id: String): String {
		this.uid = id;
		return this.uid;
	}
}

class Login extends ModelObj<Login> {
	public function new () {
		super();
	}
	public var password: String;

	public function getUri(): String {
		return throw new Exception("don't call me!");
	}
}

class LoginByUn extends Login {
	public var email: String;
	// public var agency: String;

	override public function getUri(): String {
		// return "agent://" + username + ":" + password + "@server:9876/" + agency + "?email=george@costanza.com&fullname=George+Costanza";
		return "agent://email/" + email + "?password=" + password;
	}
}

class LoginById extends Login {
	public var uuid: String;

	override public function getUri(): String {
		return uuid + "?password=" + password;
	}
}

class NewUser extends ModelObj<NewUser> {
	public var name: String;
	public var userName: String;
	public var email: String;
	public var pwd: String;

	public function new () {
		super();
	}
}

class User extends ModelObj<User> {
	public var sessionURI: String;
	public var userData: UserData; 
	@:transient public var aliasSet: ObservableSet<Alias>;
	private var aliases: Array<Alias>;
	@:isVar public var currentAlias (get,set): Alias;


	public function new () {
		super();
	}

	private function get_currentAlias(): Alias {
		if(currentAlias == null && aliasSet != null) {
			currentAlias = aliasSet.iterator().next();
		} else if (currentAlias == null) {
			currentAlias = new Alias();
			AppContext.LOGGER.warn("No aliases found for user.");
		}
		return currentAlias;
	}

	private function set_currentAlias(alias: Alias): Alias {
		currentAlias = alias;
		return currentAlias;
	}

	public function hasValidSession(): Bool {
		//TODO //IMPLEMENT ME
		AppContext.LOGGER.warn("implement User.hasValidSession");
		return true;
	}

	private function readResolve(): Void {
		aliasSet = new ObservableSet<Alias>(Alias.identifier, aliases);
	}

	private function writeResolve(): Void {
		aliases = aliasSet.asArray();
	}

	public function getSelfConnection(): Connection {
		var conn: Connection = new Connection();
		conn.source = sessionURI;
		conn.target = sessionURI;
		conn.label = currentAlias.label;
		return conn;
	}
}

class UserData extends ModelObj<UserData> {
	public var name: String;
	@:optional public var imgSrc: String;

	public function new(?name: String, ?imgSrc: String) {
		super();
		this.name = name;
		this.imgSrc = imgSrc;
	}
}

class Alias extends ModelObj<Alias> {
	@:optional public var imgSrc: String;
	public var label: String;
	@:transient public var labelSet: ObservableSet<Label>;
	private var labels: Array<Label>;
	@:transient public var connectionSet: ObservableSet<Connection>;
	private var connections: Array<Connection>;

	@:transient var loadedFromDb: Bool = false;


	public function new () {
		super();
	}

	private function readResolve(): Void {
		labelSet = new ObservableSet<Label>(Label.identifier, labels);
		connectionSet = new ObservableSet<Connection>(Connection.identifier, connections);
	}

	private function writeResolve(): Void {
		labels = labelSet.asArray();
		connections = connectionSet.asArray();
	}

	public static function identifier(alias: Alias): String {
		return alias.label;
	}
}

interface Filterable {

}

class Label extends ModelObj<Label> implements Filterable {
	public var text: String;
	@:transient public var parentUid: String;

	@:transient public var color: String;

	public function new(?text: String) {
		super();
		this.text = text;
		color = ColorProvider.getNextColor();
	}

	public static function identifier(l: Label): String {
		return l.parentUid + "_" + l.text;
	}
}

class Connection extends ModelObj<Connection> implements Filterable {
	// @:transient public var fname: String;
	// @:transient public var lname: String;
	// @:transient public var imgSrc: String;

	public var source: String;
	public var target: String;
	public var label: String;

	@:transient public var profile: UserData;

	@:transient public var connectionSet: ObservableSet<Connection>;
	@:transient public var connectionLabelSet: ObservableSet<Label>;
	@:transient public var userSharedLabelSet: ObservableSet<Label>;

	public static function identifier(c: Connection): String {
		return c.label + "_" + c.target;
	}


	public function new(?profile: UserData) {
		super();
		this.profile = profile;
	}

	public function name() : String {
		return this.profile != null ? this.profile.name : "";
	}

	public function equals(c: Connection): Bool {
		return 
			this.source == c.source &&
			this.target == c.target &&
			this.label == c.label;
	}
}

class ContentHandler implements TypeHandler {
	
    public function new() {
    }

    public function read(fromJson: {type: String}, reader: JsonReader<Dynamic>, ?instance: Dynamic): Dynamic {
        var obj: Content = null;

        switch ( ContentType.createByName(fromJson.type) ) {
        	case ContentType.AUDIO:
        		obj = AppContext.SERIALIZER.fromJsonX(fromJson, AudioContent);
        	case ContentType.IMAGE:
        		obj = AppContext.SERIALIZER.fromJsonX(fromJson, ImageContent);
        	case ContentType.TEXT:
        		obj = AppContext.SERIALIZER.fromJsonX(fromJson, MessageContent);
        	case ContentType.URL:
        		obj = AppContext.SERIALIZER.fromJsonX(fromJson, UrlContent);
        }

        return obj;
    }

    public function write(value: Dynamic, writer: JsonWriter): Dynamic {
        return AppContext.SERIALIZER.toJson(value);
    }
}

class Content extends ModelObj<Content> {
	public var type: ContentType;
	public var created: Date;
	public var modified: Date;
	
	@:transient public var labelSet: ObservableSet<Label>;
	@:transient public var connectionSet: ObservableSet<Connection>;
		
	/**
		UID of connection that created the content
	*/
	@:optional public var creator: String;

	public function new (contentType:ContentType) {
		super();
		this.type     = contentType;
		this.created  = Date.now();
		this.modified = Date.now();

        this.connectionSet = new ObservableSet<Connection>(Connection.identifier, []);
        this.labelSet = new ObservableSet<Label>(Label.identifier, []);
	}

	public function getTimestamp(): String {
		return DateTools.format(this.created, "%Y-%m-%d %T");
	}

	private function readResolve(): Void {
		// labelSet = new ObservableSet<Label>(ModelObj.identifier, labels);
		// connectionSet = new ObservableSet<Connection>(ModelObj.identifier, connections);
	}

	private function writeResolve(): Void {
		// labels = labelSet.asArray();
		// connections = connectionSet.asArray();
	}
}

class ImageContent extends Content {
	public var imgSrc: String;
	public var caption: String;

	public function new () {
		super(ContentType.IMAGE);
	}
}

class AudioContent extends Content {
	public var audioSrc: String;
	public var audioType: String;
	public var title: String;

	public function new () {
		super(ContentType.AUDIO);
	}
}

class MessageContent extends Content {
	public var text: String;

	public function new () {
		super(ContentType.TEXT);
	}
}

class UrlContent extends Content {
	public var url: String;
	public var text: String;

	public function new () {
		super(ContentType.URL);
	}	
}

enum ContentType {
	AUDIO;
	IMAGE;
	URL;
	TEXT;
}
