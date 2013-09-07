<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmCampaign.list.title" subtitle="Sökningen resulterade i ${crmCampaignTotal} st kampanjer"
            args="[entityName]">
</crm:header>


<table class="table table-striped">
    <thead>
    <tr>
        <crm:sortableColumn property="number"
                            title="${message(code: 'crmCampaign.number.label', default: 'Number')}"/>

        <crm:sortableColumn property="name"
                            title="${message(code: 'crmCampaign.name.label', default: 'Name')}"/>

        <th><g:message code="crmCampaign.parent.label" default="Parent"/></th>
        <th><g:message code="crmCampaign.handlerName.label" default="Type"/></th>
        <th><g:message code="crmCampaign.startTime.label" default="Starts"/></th>
        <th><g:message code="crmCampaign.endTime.label" default="Ends"/></th>
        <crm:sortableColumn property="status"
                            title="${message(code: 'crmCampaign.status.label', default: 'Status')}"/>
    </tr>
    </thead>
    <tbody>
    <g:each in="${crmCampaignList}" var="crmCampaign">
        <tr class="${crmCampaign.active ? '' : 'disabled'}">

            <td>
                <g:link controller="crmCampaign" action="show" id="${crmCampaign.id}">
                    ${fieldValue(bean: crmCampaign, field: "number")}
                </g:link>
            </td>

            <td>
                <g:link controller="crmCampaign" action="show" id="${crmCampaign.id}">
                    ${fieldValue(bean: crmCampaign, field: "name")}
                </g:link>
            </td>

            <td>
                <g:if test="${crmCampaign.parent}">
                    <g:link controller="crmCampaign" action="show" id="${crmCampaign.parentId}">
                        ${fieldValue(bean: crmCampaign, field: "parent")}
                    </g:link>
                </g:if>
            </td>

            <td>
                <g:if test="${crmCampaign.handlerName}">
                    ${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}
                </g:if>
            </td>

            <td>
                <g:formatDate type="date" date="${crmCampaign.startTime}"/>
            </td>

            <td>
                <g:formatDate type="date" date="${crmCampaign.endTime}"/>
            </td>

            <td>
                <g:fieldValue bean="${crmCampaign}" field="status"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:paginate total="${crmCampaignTotal}"/>

<div class="form-actions btn-toolbar">
    <crm:selectionMenu visual="primary"/>
    <div class="btn-group">
        <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                    label="crmCampaign.button.create.label" title="crmCampaign.button.create.help"
                    permission="crmCampaign:create"/>
    </div>
</div>

</body>
</html>
