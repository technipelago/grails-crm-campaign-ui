<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.show.title" args="[entityName, crmCampaign]"/></title>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <crm:header title="crmCampaign.show.title"
                    subtitle="${crmCampaign.handlerName ? message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName) : ''}"
                    args="[entityName, crmCampaign]"/>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmCampaign.tab.main.label"/></a>
                </li>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">
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

                                <g:if test="${crmCampaign.description}">
                                    <dt><g:message code="crmCampaign.description.label" default="Description"/></dt>
                                    <dd><g:decorate encode="HTML">${crmCampaign.description}</g:decorate></dd>
                                </g:if>
                            </dl>
                        </div>

                        <div class="span5">
                            <dl>

                                <g:if test="${crmCampaign.handlerName}">
                                    <dt><g:message code="crmCampaign.handler.label" default="Type"/></dt>
                                    <dd>${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}</dd>
                                </g:if>

                                <g:if test="${crmCampaign?.status}">
                                    <dt><g:message code="crmCampaign.status.label" default="Status"/></dt>

                                    <dd><g:fieldValue bean="${crmCampaign}" field="status"/></dd>
                                </g:if>

                            </dl>
                        </div>

                    </div>

                    <div class="form-actions">
                        <g:form>
                            <g:hiddenField name="id" value="${crmCampaign?.id}"/>

                            <crm:button type="link" action="edit" id="${crmCampaign?.id}" visual="primary"
                                        icon="icon-pencil icon-white"
                                        label="crmCampaign.button.edit.label" permission="crmCampaign:edit">
                            </crm:button>

                            <crm:button type="link" controller="${crmCampaign.handlerName}" action="edit"
                                        id="${crmCampaign.id}"
                                        visual="primary"
                                        icon="icon-wrench icon-white"
                                        label="crmCampaign.button.settings.label"
                                        title="crmCampaign.button.settings.help"
                                        permission="crmCampaign:edit"/>

                            <crm:button type="link" action="create"
                                        visual="success"
                                        icon="icon-file icon-white"
                                        label="crmCampaign.button.create.label"
                                        title="crmCampaign.button.create.help"
                                        permission="crmCampaign:create"/>
                        </g:form>
                    </div>

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

        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmCampaign]}"/>

    </div>
</div>

</body>
</html>
