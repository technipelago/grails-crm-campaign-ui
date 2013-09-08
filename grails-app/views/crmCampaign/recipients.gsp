<%@ page import="org.apache.commons.lang.StringUtils" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.recipients.title" args="[entityName, crmCampaign]"/></title>
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
    </style>
</head>

<body>

<crm:header title="crmCampaign.recipients.title"
            subtitle="${crmCampaign}"
            args="[entityName, crmCampaign]"/>

<div class="row-fluid">
    <table class="table table-striped">
        <thead>
        <tr>
            <th>E-post</th>
            <th>Skickat</th>
            <th>Öppnat</th>
            <th>Problem</th>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${recipients}" var="r">
            <tr class="${r.dateOptOut ? 'crm-optout' : (r.reason ? 'crm-error' : (r.dateOpened ? 'crm-opened' : ''))}">

                <td>
                    ${r.email}
                </td>

                <td><g:formatDate type="datetime" style="short" date="${r.dateSent}"/></td>
                <td><g:formatDate type="datetime" style="short" date="${r.dateOpened}"/></td>
                <td style="color: #990000;">
                    <g:if test="${r.reason}">
                        ${StringUtils.abbreviate(r.reason, 500).encodeAsHTML()}
                    </g:if>
                </td>
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
    <g:form action="recipients" class="form-inline">

        <crm:button type="link" action="show" id="${crmCampaign.id}" fragment="target" icon="icon-remove"
                    label="crmCampaign.button.back.label"/>
        <input type="hidden" name="id" value="${crmCampaign.id}"/>

        <g:textField name="email" class="input-large" placeholder="Lägg till e-postadress" required="" autofocus=""/>
        <button type="submit" class="btn btn-success">Lägg till</button>
    </g:form>
</div>

</body>
</html>
