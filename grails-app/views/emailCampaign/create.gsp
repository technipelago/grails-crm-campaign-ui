<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="campaignName" value="${message(code: 'emailCampaign.label', default: 'Email Campaign')}"/>
    <title><g:message code="emailCampaign.create.title" args="[campaignName, crmCampaign]"/></title>
</head>

<body>

<crm:header title="emailCampaign.create.title"
            subtitle="${crmCampaign.name}"/>

<table class="table table-striped">
    <thead>
    <th><g:message code="crmResourceRef.title.label" default="Title"/></th>
    <th><g:message code="crmContent.filename.label" default="Name"/></th>
    <th><g:message code="crmContent.modified.label" default="Modified"/></th>
    <th><g:message code="crmContent.length.label" default="Size"/></th>
    </thead>
    <tbody>
    <g:each in="${templates}" var="res" status="i">
        <g:set var="metadata" value="${res.metadata}"/>
        <tr class="status-${res.statusText} ${(i + 1) == params.int('selected') ? 'active' : ''}">
            <td>
                <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
                     title="${metadata.contentType}"/>
                <g:link action="create"
                        params="${[id: crmCampaign.id, template: res.id]}">
                    ${res.encodeAsHTML()}
                </g:link>
            </td>
            <td>
                <g:link action="create"
                        params="${[id: crmCampaign.id, template: res.id]}">
                    ${res.encodeAsHTML()}
                </g:link>
            </td>
            <td><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></td>
            <td>${metadata.size}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<div class="form-actions">
    <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                label="crmCampaign.button.back.label"/>
</div>

</body>
</html>