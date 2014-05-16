<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>Statistik</h4>

<g:if test="${recipients}">
    ${stats.dateOpened} st (${stats.opened}%) mottagare öppnade meddelandet.
</g:if>

<div id="chart"></div>

<style type="text/css">
#chart {
    text-align: center;
}
</style>

<script type="application/javascript">

    var dataset = [${100 - stats.opened}, ${stats.opened}];
    var w = 160;
    var h = 160;
    var outerRadius = w / 2;
    var innerRadius = 20;
    var arc = d3.svg.arc()
            .innerRadius(innerRadius)
            .outerRadius(outerRadius);

    var pie = d3.layout.pie();

    var color = d3.scale.ordinal().range(["#ddd", "#60c360"]);

    //Create SVG element
    var svg = d3.select("#chart")
            .append("svg")
            .attr("width", w)
            .attr("height", h);

    //Set up groups
    var arcs = svg.selectAll("g.arc")
            .data(pie(dataset))
            .enter()
            .append("g")
            .attr("class", "arc")
            .attr("transform", "translate(" + outerRadius + "," + outerRadius + ")");

    //Draw arc paths
    arcs.append("path")
            .attr("fill", function (d, i) {
                return color(i);
            })
            .attr("d", arc);

    //Labels
    arcs.append("text")
            .attr("transform", function (d) {
                return "translate(" + arc.centroid(d) + ")";
            })
            .attr("text-anchor", "middle")
            .text(function (d) {
                return d.value + '%';
            });
</script>