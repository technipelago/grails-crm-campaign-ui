<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaignStatus.label', default: 'Product Group')}"/>
    <title><g:message code="crmCampaignStatus.edit.title" args="[entityName, crmCampaignStatus]"/></title>
</head>

<body>

<crm:header title="crmCampaignStatus.edit.title" args="[entityName, crmCampaignStatus]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmCampaignStatus}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmCampaignStatus}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit"
                id="${crmCampaignStatus?.id}">
            <g:hiddenField name="version" value="${crmCampaignStatus?.version}"/>

            <f:with bean="crmCampaignStatus">
                <f:field property="name" input-autofocus=""/>
                <f:field property="description"/>
                <f:field property="orderIndex"/>
                <f:field property="enabled"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="primary" icon="icon-ok icon-white" label="crmCampaignStatus.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmCampaignStatus.button.delete.label"
                            confirm="crmCampaignStatus.button.delete.confirm.message"
                            permission="crmCampaignStatus:delete"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmCampaignStatus.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
