miqHttpInject(angular.module('mwTopologyApp', ['kubernetesUI', 'ui.bootstrap', 'ManageIQ']))
    .controller('middlewareTopologyController', MiddlewareTopologyCtrl);

MiddlewareTopologyCtrl.$inject = ['$scope', '$http', '$interval', "$location", 'topologyService'];

function MiddlewareTopologyCtrl($scope, $http, $interval, $location, topologyService) {
    var self = this;
    $scope.vs = null;
    var d3 = window.d3;
    var icons = null;

    $scope.refresh = function() {
        var id;
        if ($location.absUrl().match("show/$") || $location.absUrl().match("show$")) {
            id = '';
        }
        else {
            id = '/'+ (/middleware_topology\/show\/(\d+)/.exec($location.absUrl())[1]);
        }
        var currentSelectedKinds = $scope.kinds;
        var url = '/middleware_topology/data'+id;
        $http.get(url).success(function(data) {
            $scope.items = data.data.items;
            $scope.relations = data.data.relations;
            $scope.kinds = data.data.kinds;
            icons = data.data.icons;
            if (currentSelectedKinds && (Object.keys(currentSelectedKinds).length !=  Object.keys($scope.kinds).length)) {
                $scope.kinds = currentSelectedKinds;
            }
        });

    };

    $scope.checkboxModel = {
        value : false
    };
    $scope.legendTooltip = "Click here to show/hide entities of this type";

    $scope.show_hide_names = function() {
       var vertices = $scope.vs;

       if ($scope.checkboxModel.value) {
            vertices.selectAll("text.attached-label")
               .style("display", "block");
       }
       else {
           vertices.selectAll("text.attached-label")
              .style("display", "none");
       }
    };

    $scope.refresh();
    var promise = $interval( $scope.refresh, 1000*60*3);

    $scope.$on('$destroy', function() {
        $interval.cancel(promise);
    });

    $scope.$on("render", function(ev, vertices, added) {
        /*
         * We are passed two selections of <g> elements:
         * vertices: All the elements
         * added: Just the ones that were added
         */
        added.attr("class", function(d) { return d.item.kind; });
        added.append("circle")
            .attr("r", function(d) { return getCircleDimensions(d).r})
            .attr('class' , function(d) {
              return topologyService.getItemStatusClass(d);
            });
        added.append("title");
        added.on("dblclick", function(d) {
            return self.dblclick(d);});
        added.append("image")
            .attr("xlink:href",function(d) {
                var iconInfo = self.getIcon(d);
                switch(iconInfo.type) {
                    case 'image':
                        return iconInfo.icon;
                    case "glyph": // the icon will be provided as a text
                        return null;
                }
            })
            .attr("y", function(d) { return getCircleDimensions(d).y})
            .attr("x", function(d) { return getCircleDimensions(d).x})
            .attr("height", function(d) { return getCircleDimensions(d).height})
            .attr("width", function(d) { return getCircleDimensions(d).width});
        // attached labels
        added.append("text")
            .attr("x", 26)
            .attr("y", 24)
            .text(function(d) {
                return d.item.name 
            })
            .attr('class', 'attached-label')
            .style("font-size", function(d) {
                return "12px"
            })
            .style("fill", function(d) {
                return "black"
            })
            .style("display", function(d) {
                if ($scope.checkboxModel.value) {
                    return "block"
                } else {
                    return "none"
                }
            });
        // possible glyphs
        added.append("text")
            .each(function(d) {
                var iconInfo = self.getIcon(d);
                if (iconInfo.type != 'glyph') return;
                $(this).text(iconInfo.icon)
                    .attr("class", "glyph")
                    .attr('font-family', iconInfo.fontfamily)
                    .attr('style', 'fill: ' + getGlyphFeatures(d).color + ';');
            })
            .attr("x", function(d) { return getTextPosition(d).x})
            .attr("y", function(d) { return getTextPosition(d).y});
            // .text(function(d) { return d.item.name }).style("font-size", function(d) {return "12px"}).style("fill", function(d) {return "black"})
            // .style("display", function(d) {if ($scope.checkboxModel.value) {return "block"} else {return "none"}});

        added.selectAll("title").text(function(d) {
            return topologyService.tooltip(d).join("\n");
        });
        $scope.vs = vertices;

        /* Don't do default rendering */
        ev.preventDefault();
    });

    this.getIcon = function getIcon(d) {
        if (d.item.icon) {
            return {
                'type': 'image',
                'icon': "/assets/svg/" + class_name(d) + ".svg"
            }
        }
        return icons[d.item.kind]
    };

    function class_name(d) {
        var class_name = d.item.icon;
        return class_name;
    };

    this.dblclick = function dblclick(d) {
      window.location.assign(topologyService.geturl(d));
    };

    function getCircleDimensions(d) {
        switch (d.item.kind) {
            case "MiddlewareManager":
                return { x: -20, y: -20, height: 40, width: 40, r: 28};
            case "Container" :
                return { x: -7, y: -7,height: 14, width: 14, r: 13};
            case "MiddlewareServer" :
                return { x: -12, y: -12, height: 23, width: 23, r: 19};
            default :
                return { x: -9, y: -9, height: 18, width: 18, r: 17};
        }
    }

    function getTextPosition(d) {
        switch (d.item.kind) {
            case "MiddlewareDatasource" :
                return { x: 0, y: 8};
            default :
                return { x: 26, y: 24};
        }
    }

    function getGlyphFeatures(d) {
        switch (d.item.kind) {
            case "MiddlewareDatasource" :
                return { color: '#81B0C8'};
            default :
                return { color: '#000'};
        }
    }

    $scope.searchNode = function() {
      var svg = topologyService.getSVG(d3);
      var query = $scope.search.query;

      topologyService.searchNode(svg, query);
    };

    $scope.resetSearch = function() {
        topologyService.resetSearch(d3);

        // Reset the search term in search input
        $scope.search.query = "";
    };

}
