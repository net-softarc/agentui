package ui.model;

import ui.model.ModelObj;
import ui.model.Node;
import ui.model.EventModel;
import ui.observable.OSet.ObservableSet;
import ui.util.UidGenerator;

using ui.helper.ArrayHelper;

class TestDao {

	private static var connections: Array<Connection>;
	private static var labels: Array<Label>;
	private static var initialized: Bool = false;
	private static var _lastRandom: Int = 0;

	private static function buildConnections(): Void {
		connections = new Array<Connection>();
		 //connections
        var george: Connection = new Connection("George", "Costanza", "media/test/george.jpg");
        george.uid = UidGenerator.create();
        connections.push(george);

        var elaine: Connection = new Connection("Elaine", "Benes", "media/test/elaine.jpg");
        elaine.uid = UidGenerator.create();
        connections.push(elaine);

        var kramer: Connection = new Connection("Cosmo", "Kramer", "media/test/kramer.jpg");
        kramer.uid = UidGenerator.create();
        connections.push(kramer);

        var toms: Connection = new Connection("Tom's", "Restaurant", "media/test/toms.jpg");
        toms.uid = UidGenerator.create();
        connections.push(toms);

        var newman: Connection = new Connection("Newman", "", "media/test/newman.jpg");
        newman.uid = UidGenerator.create();
        connections.push(newman);
	}

	private static function buildLabels(): Void {
		labels = new Array<Label>();
		
        //labels
        var locations: Label = new Label("Locations");
        locations.uid = UidGenerator.create();
        labels.push(locations);

        var home: Label = new Label("Home");
        home.uid = UidGenerator.create();
        home.parentUid = locations.uid;
        labels.push(home);

        var city: Label = new Label("City");
        city.uid = UidGenerator.create();
        city.parentUid = locations.uid;
        labels.push(city);

        var media: Label = new Label("Media");
        media.uid = UidGenerator.create();
        labels.push(media);

        var personal: Label = new Label("Personal");
        personal.uid = UidGenerator.create();
        personal.parentUid = media.uid;
        labels.push(personal);

        var work: Label = new Label("Work");
        work.uid = UidGenerator.create();
        work.parentUid = media.uid;
        labels.push(work);

        var interests = new Label("Interests");
        interests.uid = UidGenerator.create();
        labels.push(interests);
	}

	private static function generateContent(node: Node): Array<Content> {
		var availableConnections = getConnectionsFromNode(node);
		var availableLabels = getLabelsFromNode(node);

		var content = new Array<Content>();
		var audioContent: AudioContent = new AudioContent();
        audioContent.uid = UidGenerator.create();
        audioContent.type = "AUDIO";
        audioContent.audioSrc = "media/test/hello_newman.mp3";
        audioContent.audioType = "audio/mpeg";
        audioContent.connections = new ObservableSet<Connection>(ModelObj.identifier);
        audioContent.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, audioContent, 2);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, audioContent, 2);
	    }
        audioContent.title = "Hello Newman Compilation";
        content.push(audioContent);

        var img: ImageContent = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/soupkitchen.jpg";
        img.caption = "Soup Kitchen";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 1);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 2);
	    }
        content.push(img);

        img = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/apt.jpg";
        img.caption = "Apartment";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 1);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 1);
	    }
        content.push(img);

        img = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/jrmint.jpg";
        img.caption = "The Junior Mint!";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 3);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 2);
	    }
        content.push(img);

        img = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/oldschool.jpg";
        img.caption = "Retro";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 3);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 1);
	    }
        content.push(img);

        img = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/mailman.jpg";
        img.caption = "Jerry Delivering the mail";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 1);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 1);
	    }
        content.push(img);

        img = new ImageContent();
        img.uid = UidGenerator.create();
        img.type = "IMAGE";
        img.imgSrc = "media/test/closet.jpg";
        img.caption = "Stuck in the closet!";
        img.connections = new ObservableSet<Connection>(ModelObj.identifier);
        img.labels = new ObservableSet<Label>(ModelObj.identifier);
        if(availableConnections.hasValues()) {
        	addConnections(availableConnections, img, 1);
	    }
        if(availableLabels.hasValues()) {
        	addLabels(availableLabels, img, 2);
	    }
        content.push(img);

        return content;
	}

	private static function addConnections(availableConnections: Array<Connection>, content: Content, numToAdd: Int) {
		if(availableConnections.hasValues()) {
        	if(numToAdd == 1) {
        		addOne(availableConnections, content.connections);
        	} else if(numToAdd == 2) {
        		addTwo(availableConnections, content.connections);
    		} else {
    			addAll(availableConnections, content.connections);
    		}
	    }
	}

	private static function addLabels(availableConnections: Array<Label>, content: Content, numToAdd: Int) {
		if(availableConnections.hasValues()) {
        	if(numToAdd == 1) {
        		addOne(availableConnections, content.labels);
        	} else if(numToAdd == 2) {
        		addTwo(availableConnections, content.labels);
    		} else {
    			addAll(availableConnections, content.labels);
    		}
	    }
	}

	private static function addOne<T>(available: Array<T>, arr: ObservableSet<T>) {
		// if(available.length == 1) {
  //       	arr.add(available[0]);
		// } else {
        	arr.add(getRandomFromArray(available));
    	// }
	}

	private static function addTwo<T>(available: Array<T>, arr: ObservableSet<T>) {
		if(available.length == 1) {
        	// arr.add(available[0]);
        	arr.add(getRandomFromArray(available));
		} else {
        	arr.add(getRandomFromArray(available));
        	arr.add(getRandomFromArray(available));
    	}
	}

	private static function addAll<T>(available: Array<T>, arr: ObservableSet<T>) {
		for(t_ in 0...available.length) {
			arr.add(available[t_]);
		}
	}

	private static function getRandomFromArray<T>(arr: Array<T>): T {
		var t: T = null;
		if(arr.hasValues()) {
			t = arr[Std.random(arr.length)];
		}
		return t;
	}

	private static function getConnectionsFromNode(node: Node): Array<Connection> {
		var connections: Array<Connection> = new Array<Connection>();
		if(Std.is(node, ContentNode)) {
			if(cast(node, ContentNode).type == "CONNECTION") {
				connections.push(cast(cast(node, ContentNode).filterable, Connection));
			}
		} else {
			for(n_ in 0...node.nodes.length) {
				var childNode = node.nodes[n_];
				if(Std.is(childNode, ContentNode) && cast(childNode, ContentNode).type == "CONNECTION") {
					connections.push(cast(cast(childNode, ContentNode).filterable, Connection));
				} else if (childNode.nodes.hasValues()) {
					for(nn_ in 0...childNode.nodes.length) {
						var grandChild = childNode.nodes[nn_];
						connections = connections.concat(getConnectionsFromNode(grandChild));
					}

				}
			}
		}
		return connections;
	}

	private static function getLabelsFromNode(node: Node): Array<Label> {
		var labels: Array<Label> = new Array<Label>();
		if(Std.is(node, ContentNode)) {
			if(cast(node, ContentNode).type == "LABEL") {
				labels.push(cast(cast(node, ContentNode).filterable, Label));
			}
		} else {
			for(n_ in 0...node.nodes.length) {
				var childNode = node.nodes[n_];
				if(Std.is(childNode, ContentNode) && cast(childNode, ContentNode).type == "LABEL") {
					labels.push(cast(cast(childNode, ContentNode).filterable, Label));
				} else if (childNode.nodes.hasValues()) {
					for(nn_ in 0...childNode.nodes.length) {
						var grandChild = childNode.nodes[nn_];
						labels = labels.concat(getLabelsFromNode(grandChild));
					}

				}
			}
		}
		return labels;
	}

	private static function randomizeOrder<T>(arr: Array<T>): Array<T> {
		var newArr: Array<Dynamic> = new Array<Dynamic>();
		do {
			var randomIndex: Int = Std.random(arr.length);
			newArr.push(arr[randomIndex]);
			arr.splice(randomIndex, 1);
		} while(arr.length > 0);
		return cast newArr;
	}

	private static function getRandomNumber<T>(arr: Array<T>, amount: Int): Array<T> {
		ui.AgentUi.LOGGER.debug("return " + amount);
		var newArr: Array<Dynamic> = new Array<Dynamic>();
		do {
			var randomIndex: Int = Std.random(arr.length);
			newArr.push(arr[randomIndex]);
			arr.splice(randomIndex, 1);
		} while(newArr.length < amount);
		return cast newArr;
	}

	private static function initialize(): Void {
		initialized = true;
		buildConnections();
		buildLabels();
	}

	public static function getConnections(user: User): Array<Connection> {
		if(!initialized) initialize();
		return connections;
	}

	public static function getLabels(user: User): Array<Label> {
		if(!initialized) initialize();
		return labels;
	}

	public static function getContent(node: Node): Array<Content> {
		if(!initialized) initialize();
		var arr: Array<Content> = randomizeOrder( generateContent(node) );
		return getRandomNumber(arr , Std.random(arr.length));
	}

	public static function getUser(uid: String): User {
		var user: User = new User();
        user.fname = "Jerry";
        user.lname = "Seinfeld";
        user.uid = UidGenerator.create();
        user.imgSrc = "media/test/jerry.jpg";
        user.aliases = new ObservableSet<Alias>(ModelObj.identifier);
        var alias: Alias = new Alias();
        alias.uid = UidGenerator.create();
        alias.label = "Comedian";
        user.aliases.add(alias);
        alias = new Alias();
        alias.uid = UidGenerator.create();
        alias.label = "Actor";
        user.aliases.add(alias);
        alias = new Alias();
        alias.uid = UidGenerator.create();
        alias.label = "Private";
        user.aliases.add(alias);
        return user;
	}
}