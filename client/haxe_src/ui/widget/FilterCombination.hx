package ui.widget;

import js.JQuery;
import ui.jq.JQ;
import ui.jq.JQDroppable;
import ui.jq.JQDraggable;
import ui.model.ModelObj;
import ui.observable.OSet;

using ui.helper.ArrayHelper;

typedef FilterCombinationOptions = {
	@:optional var position: {left: Int, top: Int};
	@:optional var event: JqEvent;
}

typedef FilterCombinationWidgetDef = {
	@:optional var options: FilterCombinationOptions;
	var _create: Void->Void;
	var destroy: Void->Void;
	var addFilterable: FilterableComponent->Void;
	var removeFilterable: FilterableComponent->Void;
	var _add: FilterableComponent->Void;
	var _remove: FilterableComponent->Void;
	var _layout: Void->Void;
	var position: Void->Void;
	@:optional var _filterables: ObservableSet<FilterableComponent>;
}

extern class FilterCombination extends JQ {

	@:overload(function(cmd : String):Bool{})
	@:overload(function(cmd : String, arg: Dynamic):Void{})
	@:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
	function filterCombination(?opts: FilterCombinationOptions): FilterCombination;

	private static function __init__(): Void {
		untyped FilterCombination = window.jQuery;
		var defineWidget: Void->FilterCombinationWidgetDef = function(): FilterCombinationWidgetDef {
			return {
		        _create: function(): Void {
		        	var self: FilterCombinationWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();

		        	if(!selfElement.is("div")) {
		        		throw new ui.exception.Exception("Root of FilterCombination must be a div element");
		        	}
					
					self._filterables = new ObservableSet<FilterableComponent>(function (fc: FilterableComponent): String { return cast(fc, JQ).attr("id");});
					self._filterables.listen(function(fc: FilterableComponent, evt: EventType): Void {
		            		if(evt.isAdd()) {
		            			self._add(fc);
		            		} else if (evt.isUpdate()) {
		            			// fc.labelTreeBranch("update");
		            		} else if (evt.isDelete()) {
		            			self._remove(fc);
		            		}
		            	});

		        	//classes
		        	//- connectionTD & labelDT such that this is a valid drop target for connections and labels, respectively
		        	//- filterCombination to give this element its styling for css purposes
		        	//- filterTrashable so this element can be trashed
		        	//- dropCombiner is used to identify what kinds of elements are accepted by connections and labels
		        	//- ui-state-highlight gives the yellow background
		        	//- container rounds the corners and gives a blue border
		        	//- shadow gives a box shadow

		        	selfElement.addClass("ui-state-highlight connectionDT labelDT dropCombiner filterCombination filterTrashable container shadow" + Widgets.getWidgetClasses());

		        	selfElement.position({
		        		my: "bottom right",
		        		at: "left top",
		        		of: self.options.event,
		        		collision: "flipfit",
		        		within: "#filter"
	        		});

		        	var toggle: JQ = new JQ("<div class='andOrToggle'></div>");
		        	var and: JQ = new JQ("<div class='ui-widget-content ui-state-active ui-corner-top'>Any</div>");
		        	var or: JQ = new JQ("<div class='ui-widget-content ui-corner-bottom'>All</div>");
		        	toggle.append(and).append(or);
		        	var children: JQ = toggle.children();
		        	children
		        		.hover(
			        		function(evt: JqEvent): Void {
			        			JQ.cur.addClass("ui-state-hover");
		        			},
			        		function(): Void {
			        			JQ.cur.removeClass("ui-state-hover");
			        		}
		        		)
		        		.click(
		        			function(evt: JqEvent): Void {
		        				children.toggleClass("ui-state-active");
		        			}
	        			);
	        		selfElement.append(toggle);

		        	cast(selfElement, JQDraggable).draggable({
			    		containment: "parent", 
			    		distance: 10,
			    		// grid: [5,5],
			    		scroll: false
				    });

					cast(selfElement, JQDroppable).droppable({
			    		accept: function(d) {
			    			return d.is(".filterable");
			    		},
						activeClass: "ui-state-hover",
				      	hoverClass: "ui-state-active",
				      	greedy: true,
				      	drop: function( event: JqEvent, _ui: UIDroppable ) {
			                //fire off a filterable
				      		var clone: FilterableComponent = _ui.draggable.data("clone")(_ui.draggable,false,"#filter");
			                clone.addClass("filterTrashable " + _ui.draggable.data("dropTargetClass"))
			      				.appendTo(selfElement)
				      			.css("position", "absolute")
				      			.css({left: "", top: ""});

			      			self.addFilterable(clone);

			      			selfElement.position({
				      				collision: "flipfit",
			        				within: "#filter"
			      				});
				      	},
				      	tolerance: "pointer"
				    });
		        },

		        position: function(): Void {
		        	var self: FilterCombinationWidgetDef = Widgets.getSelf();
		        	var selfElement: JQ = Widgets.getSelfElement();
		        	selfElement.position({
		        		my: "center",
		        		at: "center",
		        		of: self.options.event,
		        		collision: "flipfit",
		        		within: "#filter"
	        		});
	        	},

		        addFilterable: function(filterable: FilterableComponent): Void {
		        	var self: FilterCombinationWidgetDef = Widgets.getSelf();
		        	self._filterables.add(filterable);
	        	},

	        	removeFilterable: function(filterable: FilterableComponent): Void {
		        	var self: FilterCombinationWidgetDef = Widgets.getSelf();
		        	self._filterables.delete(filterable);
	        	},

	        	_add: function(filterable: FilterableComponent): Void {
	        		var self: FilterCombinationWidgetDef = Widgets.getSelf();
		        	var selfElement: JQ = Widgets.getSelfElement();
		        	var jq: JQ = cast(filterable, JQ);
		        	jq
		      			.appendTo(selfElement)
		      			// .css("position", "relative")
		      			.css("position", "absolute")
		      			.css({left: "", top: ""})
		      			;

		        	self._layout();
	        	},

	        	_remove: function(filterable: FilterableComponent): Void {
	        		var self: FilterCombinationWidgetDef = Widgets.getSelf();
	        		var selfElement: JQ = Widgets.getSelfElement();

		        	var iter: Iterator<FilterableComponent> = self._filterables.iterator();
		        	if( iter.hasNext() ) {
		        		var filterable: FilterableComponent = iter.next();
		        		if(iter.hasNext()) {
			        		self._layout();
			        	} else {
			        		//there is only one more filterable left
			        		var jq: JQ = cast(filterable, JQ);
			        		var position: {top: Int, left: Int} = jq.offset();
		        			jq
			        			.appendTo(selfElement.parent())
		        				.offset(position)
			                	;
		        			selfElement.remove();
		        			self.destroy();
			        	}
		        	} else {
		        		self.destroy();
		        		selfElement.remove();
		        	}
	        	},

	        	_layout: function(): Void {
	        		var self: FilterCombinationWidgetDef = Widgets.getSelf();
		        	var selfElement: JQ = Widgets.getSelfElement();

	        		var filterableConns: OSet<FilterableComponent> = new FilteredSet<FilterableComponent>(self._filterables, function(fc: FilterableComponent): Bool { 
                        return fc.hasClass("connectionAvatar");
                    });

                    var filterableLabels: OSet<FilterableComponent> = new FilteredSet<FilterableComponent>(self._filterables, function(fc: FilterableComponent): Bool { 
                        return fc.hasClass("label");
                    });

                    var leftPadding: Int = 30;
                    var topPadding: Int = 6;
                    var typeGap: Int = 10;
                    var rowGap: Int = 50;

                    var iterC: Iterator<FilterableComponent> = filterableConns.iterator();
                    var connCount: Int = 0;
                    var connPairs: Int = 0;
                    while(iterC.hasNext()) {
                    	connCount++;
                    	connPairs = Std.int(connCount / 2) + connCount % 2;
                    	var connAvatar: FilterableComponent = iterC.next();
                    	connAvatar.css({
                    		"left": leftPadding + (35 * (connPairs-1)),
                    		"top": topPadding + (rowGap * (connCount+1) % 2)
                		});
                    }

                    var connectionWidth = 35 * connPairs;

                    var iterL: Iterator<FilterableComponent> = filterableLabels.iterator();
                    var labelCount: Int = 0;
                    var labelPairs: Int = 0;
                    while(iterL.hasNext()) {
                    	labelCount++;
                    	labelPairs = Std.int(labelCount / 2) + labelCount % 2;
                    	var labelComp: FilterableComponent = iterL.next();
                    	labelComp.css({
                    		"left": leftPadding + connectionWidth + typeGap + (135 * (labelPairs-1)),
                    		"top": topPadding + (rowGap * (labelCount+1) % 2)
                		});
                    }

		        	selfElement.css ( {
						"width": (35 * connPairs + 135 * labelPairs) + "px",
						"min-width": (35 * connPairs + 135 * labelPairs) + "px"
	        		});
	        	},

	        	
		        
		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.filterCombination", defineWidget());
	}
}