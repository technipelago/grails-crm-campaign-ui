<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.recipients.title" args="[entityName, crmCampaign]"/></title>
</head>

<body>

<crm:header title="crmCampaign.recipients.title"
            subtitle="${crmCampaign}"
            args="[entityName, crmCampaign]"/>

<g:form action="recipients" class="form-inline">
    <input type="hidden" name="id" value="${crmCampaign.id}"/>

    <div class="control-group">
        <label class="control-label">Lägg till mottagare (${totalCount} st)</label>

        <div class="controls">
            <g:textField name="email" class="input-large" autofocus=""/>
            <button type="submit" class="btn btn-success">Lägg till</button>
        </div>
    </div>
</g:form>

<div class="row-fluid">
    <table class="table table-striped">
        <thead>
        <tr>
            <th>E-post</th>
            <th>Skickat</th>
            <th>Öppnat</th>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${recipients}" var="r">
            <tr class="${r.dateOptOut ? 'disabled' : ''}">

                <td>
                    ${r.email}
                </td>

                <td><g:formatDate type="datetime" style="short" date="${r.dateSent}"/></td>
                <td><g:formatDate type="datetime" style="short" date="${r.dateOpened}"/></td>
                <td>
                    <g:link action="deleteRecipient" id="${r.id}" title="Ta bort mottagare"
                            onclick="return confirm('Är du säker på att du vill ta bort mottagaren?')"><i
                            class="icon-trash"></i></g:link>
                </td>
            </tr>
        </g:each>
        </tbody>
    </table>

    <crm:paginate total="${totalCount}"/>
</div>

<div class="form-actions">
    <crm:button type="link" action="show" id="${crmCampaign.id}" fragment="target" icon="icon-remove"
                label="crmCampaign.button.back.label"/>
</div>

</body>
</html>
