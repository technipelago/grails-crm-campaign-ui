<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.find.title" args="[entityName]"/></title>
    <r:require modules="datepicker"/>
    <r:script>
        $(document).ready(function () {
            <crm:datepicker/>
        });
    </r:script>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <crm:header title="crmCampaign.find.title" args="[entityName]"/>

        <g:form action="list">

            <div class="row-fluid">

                <f:with bean="cmd">
                    <div class="span4">
                        <div class="row-fluid">
                            <f:field property="number" label="crmCampaign.number.label"
                                     input-class="span12" input-autofocus=""
                                     input-placeholder="${message(code: 'crmCampaignQueryCommand.number.placeholder', default: '')}"/>
                            <f:field property="name" label="crmCampaign.name.label"
                                     input-class="span12"
                                     input-placeholder="${message(code: 'crmCampaignQueryCommand.name.placeholder', default: '')}"/>
                        </div>
                    </div>

                    <div class="span4">
                        <div class="row-fluid">
                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmCampaignQueryCommand.fromDate.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(format: 'yyyy-MM-dd', date: cmd.fromDate ?: new Date())}">
                                        <g:textField name="fromDate" class="span12" placeholder="ÅÅÅÅ-MM-DD"
                                                     value="${formatDate(format: 'yyyy-MM-dd', date: cmd.fromDate)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmCampaignQueryCommand.toDate.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(format: 'yyyy-MM-dd', date: cmd.toDate ?: new Date())}">
                                        <g:textField name="toDate" class="span12" placeholder="ÅÅÅÅ-MM-DD"
                                                     value="${formatDate(format: 'yyyy-MM-dd', date: cmd.toDate)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                            <f:field property="status" label="crmCampaign.status.label"
                                     input-class="span11"
                                     input-placeholder="${message(code: 'crmCampaignQueryCommand.status.placeholder', default: '')}"/>
                        </div>
                    </div>

                    <div class="span4">
                        <div class="row-fluid">
                            <f:field property="handlerName" label="crmCampaign.handlerName.label">
                                <g:select name="handlerName" from="${campaignTypes}" class="span11"
                                          noSelection="['': '']"
                                          optionValue="${{ message(code: it + '.label', default: it) }}"/>
                            </f:field>
                            <f:field property="parent" label="crmCampaign.parent.label"
                                     input-class="span11"
                                     input-placeholder="${message(code: 'crmCampaignQueryCommand.parent.placeholder', default: '')}"/>
                        </div>
                    </div>

                </f:with>

            </div>

            <div class="form-actions btn-toolbar">
                <crm:selectionMenu visual="primary">
                    <crm:button action="list" icon="icon-search icon-white" visual="primary"
                                label="crmCampaign.button.search.label"/>
                </crm:selectionMenu>
                <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                            label="crmCampaign.button.create.label" title="crmCampaign.button.create.help"
                            permission="crmCampaign:create"/>

                <g:link action="clearQuery" class="btn btn-link"><g:message code="crmCampaign.button.query.clear.label"
                                                                            default="Reset fields"/></g:link>
            </div>

        </g:form>
    </div>

    <div class="span3">
        <g:if test="${activeCampaigns}">
            <ul class="nav nav-list">
                <li class="nav-header">Aktiva kampanjer</li>
                <g:each in="${activeCampaigns}" var="c">
                    <li><g:link action="show" id="${c.id}">${c.encodeAsHTML()}</g:link></li>
                </g:each>
            </ul>
        </g:if>
    </div>
</div>

</body>
</html>
