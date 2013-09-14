<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmCampaignTarget.orderIndex.label" default="#"/></th>
        <th><g:message code="crmCampaignTarget.operation.label" default="Operation"/></th>
        <th><g:message code="crmCampaignTarget.name.label" default="Selection"/></th>
        <th style="width:20px;"></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="target">
        <tr>
            <g:form controller="crmCampaignTarget" action="delete" id="${target.id}" class="form-inline">
                <td><g:link controller="crmCampaignTarget" action="edit"
                            id="${target.id}">${target.orderIndex}</g:link></td>
                <td><g:link controller="crmCampaignTarget" action="edit"
                            id="${target.id}">${message(code: 'crmCampaignTarget.operation.' + target.operation, default: target.operation.toString())}</g:link></td>
                <td><g:link controller="crmCampaignTarget" action="edit" id="${target.id}">${target.name}</g:link></td>
                <td style="width:20px;">
                    <button type="submit" class="btn btn-link"
                            onclick="return confirm('Är du säker på att du vill ta bort raden?')"><i
                            class="icon-trash"></i></button>
                </td>
            </g:form>
        </tr>
    </g:each>
    <tfoot>
    <tr>
        <g:form controller="crmCampaignTarget" action="add" id="${bean.id}" class="form-inline">
            <td><g:textField name="orderIndex" value="" maxlength="5" class="input-small"/></td>
            <td>
                <g:select name="operation" value="" maxlength="5" style="width:95%;" noSelection="['': '']"
                          from="[0, -1, 1]" valueMessagePrefix="crmCampaignTarget.operation"/>
            </td>
            <td>
                <g:select name="selection" from="${availableSelections}" optionKey="id" optionValue="name"
                          noSelection="['': '']" style="width:95%;"/>
            </td>
            <td style="width:20px;">
                <button type="submit" class="btn btn-link"><i class="icon-plus"></i></button>
            </td>
        </g:form>
    </tr>
    </tfoot>
    </tbody>
</table>


<g:form controller="crmCampaignTarget" action="index">
    <g:hiddenField name="id" value="${bean.id}"/>

    <div class="form-actions btn-toolbar">

        <crm:button type="link" action="recipients" id="${bean.id}"
                    visual="info" group="true"
                    icon="icon-eye-open icon-white"
                    label="${message(code: 'crmCampaign.button.recipients.label', default: 'Show {0} recipients', args: [recipientsCount])}"
                    title="crmCampaign.button.recipients.help">
            <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
            </button>
            <ul class="dropdown-menu">
                <li>
                    <g:link controller="crmCampaignTarget" action="count" id="${bean.id}" elementId="countRecipients"
                            title="${message(code: 'crmCampaign.button.target.count.help')}">
                        <g:message code="crmCampaign.button.target.count.label"/>
                    </g:link>
                </li>
            </ul>
        </crm:button>

        <crm:button action="execute" visual="warning" icon="icon-play icon-white"
                    label="crmCampaign.button.target.execute.label"
                    title="crmCampaign.button.target.execute.help"
                    confirm="crmCampaignRecipient.button.execute.confirm.message"
                    permission="crmCampaign:execute"/>

        <crm:button action="deleteRecipients" visual="danger" icon="icon-trash icon-white"
                    label="crmCampaign.recipients.button.delete.label"
                    title="crmCampaign.recipients.button.delete.help"
                    confirm="crmCampaignRecipient.button.delete.confirm.message"
                    permission="crmCampaign:edit"/>
    </div>
</g:form>

<div class="modal hide fade" id="countRecipientsModal">
    <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>

        <h3><g:message code="crmCampaign.button.target.count.label"/></h3>
    </div>

    <div class="modal-body"><!-- This space is loaded by CrmCampaignTargetController#count() --></div>

    <div class="modal-footer">
        <a href="#" class="btn btn-success" data-dismiss="modal">
            <i class="icon-ok icon-white"></i>
            <g:message code="crmCampaignRecipient.button.close.label" default="Close"/>
        </a>
    </div>
</div>

<r:script>
    $(document).ready(function () {
        $("#countRecipients").click(function (ev) {
            ev.preventDefault();
            // Load modal form with result.
            $("#countRecipientsModal .modal-body").load($(this).attr('href'), function () {
                $("#countRecipientsModal").modal('show');
            });
            return false;
        });
    });
</r:script>