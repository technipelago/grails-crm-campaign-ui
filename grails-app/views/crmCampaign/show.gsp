<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.show.title" args="[entityName, crmCampaign]"/></title>
    <r:require module="d3"/>
    <r:script>
    $(document).ready(function() {
        <% if (crmCampaign.handlerName) { %>
        $("#summary").load("${createLink(controller: crmCampaign.handlerName, action: 'summary', id: crmCampaign.id)}", function(data) {
            if(data) {
                $("#summary").show();
            }
        });
        $("#statistics").load("${
            createLink(controller: crmCampaign.handlerName, action: 'statistics', id: crmCampaign.id)}", function(data) {
            if(data) {
                $("#statistics").show();
            }
        });
        <% } %>
        });
    </r:script>
    <style type="text/css">
    tr.crm-opened td {
        color: #009900;
        background-color: #eeffee;
    }

    tr.crm-optout td {
        color: #999999;
        text-decoration: line-through;
    }

    tr.crm-error td {
        color: #990000;
        background-color: #ffe0e0;
    }

    tr.selected td {
        background-color: #f9ccff !important;
    }

    tr.crm-recipient i {
        margin-right: 5px;
    }

    tr.crm-recipient i:last-child {
        margin-right: 0;
    }

    .crm-search input {
        margin-bottom: 0;
        padding: 1px 4px;
    }

    .crm-search input.hide {
        display: none !important;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <h1>
                <g:message code="crmCampaign.show.title" args="[entityName, crmCampaign]"/>
                <g:if test="${crmCampaign.parent}">
                    <small><g:fieldValue bean="${crmCampaign}" field="parent"/></small>
                </g:if>

                <g:if test="${crmCampaign.active}">
                    <span class="label label-important"><g:message code="crmCampaign.active.label"
                                                                   default="Active"/></span>
                </g:if>
            </h1>

        </header>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmCampaign.tab.main.label"/></a>
                </li>
                <li><a href="#target" data-toggle="tab"><g:message
                        code="crmCampaign.tab.target.label"/><crm:countIndicator
                        count="${crmCampaign.target.size()}"/></a>
                </li>
                <li><a href="#recipients" data-toggle="tab"><g:message
                        code="crmCampaign.tab.recipients.label"/><crm:countIndicator
                        count="${recipientsCount}"/></a>
                </li>
                <li><a href="#children" data-toggle="tab"><g:message
                        code="crmCampaign.tab.children.label"/><crm:countIndicator
                        count="${crmCampaign.children.size()}"/></a>
                </li>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">
                    <div class="row-fluid">
                        <div class="span8">
                            <div class="row-fluid">
                                <div class="span7">
                                    <dl>
                                        <g:if test="${crmCampaign.number}">
                                            <dt><g:message code="crmCampaign.number.label" default="Number"/></dt>
                                            <dd><g:fieldValue bean="${crmCampaign}" field="number"/></dd>
                                        </g:if>

                                        <g:if test="${crmCampaign.code}">
                                            <dt><g:message code="crmCampaign.code.label" default="Code"/></dt>
                                            <dd><g:fieldValue bean="${crmCampaign}" field="code"/></dd>
                                        </g:if>

                                        <g:if test="${crmCampaign.name}">
                                            <dt><g:message code="crmCampaign.name.label" default="Name"/></dt>

                                            <dd><g:fieldValue bean="${crmCampaign}" field="name"/></dd>
                                        </g:if>
                                    </dl>
                                </div>

                                <div class="span5">
                                    <dl>
                                        <g:if test="${crmCampaign.startTime}">
                                            <dt><g:message code="crmCampaign.startTime.label" default="Starts"/></dt>
                                            <dd class="nowrap"><g:formatDate date="${crmCampaign.startTime}"
                                                                             type="datetime"/></dd>
                                        </g:if>
                                        <g:if test="${crmCampaign.endTime}">
                                            <dt><g:message code="crmCampaign.endTime.label" default="Ends"/></dt>
                                            <dd class="nowrap"><g:formatDate date="${crmCampaign.endTime}"
                                                                             type="datetime"/></dd>
                                        </g:if>

                                        <dt><g:message code="crmCampaign.status.label" default="Status"/></dt>

                                        <dd>${crmCampaign.active ? 'Aktiv' : 'Inaktiv'}</dd>
                                    </dl>
                                </div>

                            </div>

                            <g:if test="${crmCampaign.description}">
                                <dl style="margin-top: 0;">
                                    <dt><g:message code="crmCampaign.description.label" default="Description"/></dt>
                                    <dd><g:decorate encode="HTML">${crmCampaign.description}</g:decorate></dd>
                                </dl>
                            </g:if>
                        </div>

                        <div class="span4">
                            <dl>

                                <g:if test="${crmCampaign.parent}">
                                    <dt><g:message code="crmCampaign.parent.label"/></dt>
                                    <dd>
                                        <g:link action="show" id="${crmCampaign.parentId}" fragment="children">
                                            <g:fieldValue bean="${crmCampaign}" field="parent"/>
                                        </g:link>
                                    </dd>
                                </g:if>
                                <g:if test="${crmCampaign.handlerName}">
                                    <dt><g:message code="crmCampaign.handlerName.label" default="Type"/></dt>
                                    <dd>${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}</dd>
                                </g:if>

                                <dt><g:message code="crmCampaign.publicId.label" default="ID"/></dt>
                                <dd><g:fieldValue bean="${crmCampaign}" field="publicId"/></dd>
                            </dl>
                        </div>
                    </div>

                    <div class="form-actions btn-toolbar">
                        <crm:selectionMenu location="crmCampaign" visual="primary">
                            <crm:button type="link" controller="crmCampaign" action="index"
                                        visual="primary" icon="icon-search icon-white"
                                        label="crmCampaign.button.find.label" permission="crmCampaign:show"/>
                        </crm:selectionMenu>

                        <crm:button type="link" action="edit" id="${crmCampaign?.id}" visual="warning"
                                    icon="icon-pencil icon-white"
                                    label="crmCampaign.button.edit.label" permission="crmCampaign:edit">
                        </crm:button>

                        <g:if test="${crmCampaign.handlerName}">
                            <crm:button type="link" controller="${crmCampaign.handlerName}" action="edit"
                                        id="${crmCampaign.id}"
                                        visual="warning"
                                        icon="icon-wrench icon-white"
                                        label="${crmCampaign.handlerName}.button.settings.label"
                                        title="crmCampaign.button.settings.help"
                                        permission="crmCampaign:edit"/>
                        </g:if>

                        <crm:button type="link" group="true" action="create"
                                    visual="success"
                                    icon="icon-file icon-white"
                                    label="crmCampaign.button.create.label"
                                    title="crmCampaign.button.create.help"
                                    permission="crmCampaign:create">
                            <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                                <span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu">
                                <li>
                                    <g:link action="copy" id="${crmCampaign?.id}"
                                            onclick="return confirm('Är du säker på att du vill kopiera denna kampanj?')">
                                        <g:message code="crmCampaign.button.copy.label" default="Copy Campaign"/>
                                    </g:link>
                                </li>
                            </ul>
                        </crm:button>

                    </div>

                </div>

                <div class="tab-pane" id="target">
                    <tmpl:target bean="${crmCampaign}" list="${crmCampaign.target}"/>
                </div>

                <div class="tab-pane" id="recipients">
                    <tmpl:recipients bean="${crmCampaign}"/>
                </div>

                <div class="tab-pane" id="children">
                    <tmpl:children bean="${crmCampaign}" list="${crmCampaign.children}"/>
                </div>

                <crm:pluginViews location="tabs" var="view">
                    <div class="tab-pane tab-${view.id}" id="${view.id}">
                        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
                    </div>
                </crm:pluginViews>
            </div>

        </div>

    </div>

    <div class="span3">

        <div id="summary" class="alert alert-${crmCampaign.active ? 'error' : 'info'} hide">
            <%-- <g:render template="summary" model="${[bean: crmCampaign]}"/> --%>
        </div>

        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmCampaign]}"/>

        <div id="statistics" class="well well-small hide">
            <%-- This space is rendered by the campaign controller --%>
        </div>
    </div>
</div>

</body>
</html>
