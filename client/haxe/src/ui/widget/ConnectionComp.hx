package ui.widget;

import m3.util.M;
import m3.jq.JQ;
import m3.jq.JQDroppable;
import m3.jq.JQDraggable;
import m3.widget.Widgets;
import ui.model.ModelObj;
import m3.observable.OSet.ObservableSet;
import m3.exception.Exception;

using ui.widget.ConnectionAvatar;
using m3.helper.StringHelper;

typedef ConnectionCompOptions = {
	var connection: Connection;
	@:optional var classes: String;
}

typedef ConnectionCompWidgetDef = {
	var options: ConnectionCompOptions;
	var _create: Void->Void;
	@:optional var _avatar: ConnectionAvatar;
	@:optional var _notifications: JQ;
	var update: Void->Void;
	var destroy: Void->Void;
	var addNotification: Void->Void;
}

class ConnectionCompHelper {
	public static function connection(c: ConnectionComp): Connection {
		return c.connectionComp("option", "connection");
	}

	public static function addNotification(c: ConnectionComp): Void {
		return c.connectionComp("addNotification");
	}
}


@:native("$")
extern class ConnectionComp extends JQ {
	@:overload(function<T>(cmd : String):T{})
	@:overload(function<T>(cmd:String, opt:String):T{})
	@:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
	function connectionComp(opts: ConnectionCompOptions): ConnectionComp;

	private static function __init__(): Void {
		var defineWidget: Void->ConnectionCompWidgetDef = function(): ConnectionCompWidgetDef {
			return {
		        options: {
		            connection: null,
		            classes: null
		        },
		        
		        _create: function(): Void {
		        	var self: ConnectionCompWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();
					if(!selfElement.is("div")) {
		        		throw new Exception("Root of ConnectionComp must be a div element");
		        	}

		        	selfElement.addClass(Widgets.getWidgetClasses() + " connection container boxsizingBorder");
		        	self._avatar = new ConnectionAvatar("<div class='avatar'></div>").connectionAvatar({
		        		connection: self.options.connection,
		        		dndEnabled: true,
		        		isDragByHelper: true,
		        		containment: false
	        		});
	        		var notificationDiv: JQ = new JQ(".notifications", selfElement);
					if(!notificationDiv.exists()) {
						notificationDiv = new JQ("<div class='notifications'>1</div>");
					}

					notificationDiv.appendTo(selfElement);
		            selfElement.append(self._avatar);
		            selfElement.append("<div class='name'>" + self.options.connection.name() + "</div>");
		            selfElement.append("<div class='clear'></div>");
		        
		            cast(selfElement, JQDroppable).droppable({
			    		accept: function(d) {
			    			return d.is(".connectionAvatar");
			    		},
						activeClass: "ui-state-hover",
				      	hoverClass: "ui-state-active",
				      	greedy: true, 	 	
				      	drop: function( event: JQEvent, _ui: UIDroppable ) {
				      		var dropper:Connection = cast(_ui.draggable, ConnectionAvatar).getConnection();
				      		var droppee:Connection = self.options.connection;

				      		if (dropper.uid != droppee.uid) {
					      		ui.widget.DialogManager.requestIntroduction(dropper, droppee);
					      	}
				      	},
				      	tolerance: "pointer"
			    	});

		        },

		        update: function(): Void {
		        	var self: ConnectionCompWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();

					var imgSrc: String = "media/default_avatar.jpg";
		        	if(M.getX(self.options.connection.profile.imgSrc, "").isNotBlank() ) {
		        		imgSrc = self.options.connection.profile.imgSrc;
		        	}

		        	selfElement.children("img").attr("src", imgSrc);
		            selfElement.children("div").text(M.getX(self.options.connection.profile.name, ""));

		            self._avatar.connectionAvatar("update");
	        	},

	        	addNotification: function(): Void {
	        		var self: ConnectionCompWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();

					var notificationDiv: JQ = new JQ(".notifications", selfElement);
					notificationDiv.css("visibility", "visible");
        		},
		        
		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.connectionComp", defineWidget());
	}	
}