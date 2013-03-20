<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.find.title" args="[entityName]"/></title>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <crm:header title="crmCampaign.find.title" args="[entityName]"/>

        <g:form action="list">

            <div class="row-fluid">

                <f:with bean="cmd">
                    <div class="span4">
                        <f:field property="number" label="crmCampaign.number.label"
                                 input-class="input-large" input-autofocus=""
                                 input-placeholder="${message(code: 'crmCampaignQueryCommand.number.placeholder', default: '')}"/>
                        <f:field property="name" label="crmCampaign.name.label"
                                 input-class="input-large"
                                 input-placeholder="${message(code: 'crmCampaignQueryCommand.name.placeholder', default: '')}"/>
                    </div>

                    <div class="span4">
                        <f:field property="status" label="crmCampaign.status.label"
                                 input-class="input-large"
                                 input-placeholder="${message(code: 'crmCampaignQueryCommand.status.placeholder', default: '')}"/>
                    </div>

                    <div class="span4">
                    </div>

                </f:with>

            </div>

            <div class="form-actions btn-toolbar">
                <crm:selectionMenu visual="primary">
                    <crm:button action="list" icon="icon-search icon-white" visual="primary"
                                label="crmCampaign.button.find.label"/>
                </crm:selectionMenu>
                <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                            label="crmCampaign.button.create.label" permission="crmCampaign:create"/>
            </div>

        </g:form>
    </div>

    <div class="span3">
    </div>
</div>

</body>
</html>
