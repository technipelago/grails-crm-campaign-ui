<%@ page import="org.apache.commons.lang.StringUtils" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.recipients.title" args="[entityName, crmCampaign]"/></title>
    <r:script>
        $(document).ready(function () {
            // Show detailed recipient information in a popover when user hovers over the email address.
            $("a.crm-info").popover({
                trigger: 'hover',
                html: true,
                title: "${message(code: 'crmCampaign.recipients.title', args: [entityName, crmCampaign])}",
                content: function () {
                    var html = '';
                    $.ajax({
                        url: $(this).attr('href'),
                        success: function (data) { html = data; },
                        async: false
                    });
                    return html;
                }
            });
            $("a.crm-info").click(function (ev) {
                ev.preventDefault();
                // Show modal dialog with same recipient information as the popover above.
                $("#recipient-modal .modal-body").load($(this).attr('href'), function () {
                    $("#recipient-modal").modal('show');
                });
            });
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
    </style>
</head>

<body>

<crm:header title="crmCampaign.recipients.title"
            subtitle="${crmCampaign}"
            args="[entityName, crmCampaign]"/>

<h2><g:message code="crmCampaign.recipients.count.label" args="${[totalCount]}"/>
    <small><g:message code="crmCampaign.recipients.hits.label" args="${[hitCount]}"/></small>
</h2>

<div class="row-fluid">
    <table class="table table-striped crm-recipients">
        <thead>
        <tr>
            <g:sortableColumn property="email" params="${[id: params.id]}" titleKey="crmCampaignRecipient.email.label">
                <g:message code="crmCampaignRecipient.email.label"/>
            </g:sortableColumn>
            <g:sortableColumn property="dateSent" params="${[id: params.id]}"
                              titleKey="crmCampaignRecipient.dateSent.label">
                <g:message code="crmCampaignRecipient.dateSent.label"/>
            </g:sortableColumn>
            <g:sortableColumn property="dateOpened" params="${[id: params.id]}"
                              titleKey="crmCampaignRecipient.dateOpened.label">
                <g:message code="crmCampaignRecipient.dateOpened.label"/>
            </g:sortableColumn>
            <g:sortableColumn property="reason" params="${[id: params.id]}"
                              titleKey="crmCampaignRecipient.reason.label">
                <g:message code="crmCampaignRecipient.reason.label"/>
            </g:sortableColumn>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${recipients}" var="r">
            <tr class="${r.dateOptOut ? 'crm-optout' : (r.reason ? 'crm-error' : (r.dateOpened ? 'crm-opened' : ''))}">

                <td>
                    <g:link action="showRecipient" id="${r.id}" class="crm-info">
                        <g:fieldValue bean="${r}" field="email"/>
                    </g:link>
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

    <crm:paginate total="${totalCount}" params="${[id: params.id]}"/>
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


<div id="recipient-modal" class="modal hide fade">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

        <h3>
            <g:message code="crmCampaign.recipients.title" args="[entityName, crmCampaign]"/>
            <small>${crmCampaign.encodeAsHTML()}</small>
        </h3>
    </div>

    <div class="modal-body">
        <p></p>
    </div>

    <div class="modal-footer">
        <a href="#" class="btn" data-dismiss="modal">
            <i class="icon-remove"></i>
            <g:message code="crmCampaignRecipient.button.close.label" default="Close"/>
        </a>
    </div>
</div>
</body>
</html>
